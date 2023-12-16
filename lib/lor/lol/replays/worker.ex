defmodule Lor.Lol.Replays.Worker do
  @moduledoc """
  Worker GenServer to download the replays file
  """
  use GenServer, restart: :temporary

  require Logger

  defstruct ~w(
    id manager_pid platform_id active_game game_id
    replay_id
    metadata client version current_chunk_id chunk_infos
    chunk_statuses key_frame_statuses tasks
  )a

  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  # Callbacks

  @impl true
  def init(args) do
    Logger.info("Start a new Replays worker: #{args.id}")

    state = %__MODULE__{
      id: args.id,
      manager_pid: args.manager_pid,
      platform_id: args.platform_id,
      active_game: args.active_game,
      game_id: args.active_game["gameId"],
      current_chunk_id: 1,
      chunk_infos: [],
      chunk_statuses: %{},
      key_frame_statuses: %{},
      tasks: MapSet.new()
    }

    # Makes the process call terminate/2 upon exit.
    Process.flag(:trap_exit, true)

    {:ok, state, {:continue, :start}}
  end

  # Give up after 10 retry
  defp fetch_game_meta_data(platform_id, game_id, retry_count \\ 0)

  defp fetch_game_meta_data(_, _, 10) do
    {:error, :game_meta_data}
  end

  defp fetch_game_meta_data(platform_id, game_id, retry_count) do
    Logger.debug("fetch_game_meta_data #{retry_count}")

    case Lor.Lol.Observer.fetch_game_meta_data(platform_id, game_id) do
      {:ok, metadata} ->
        {:ok, metadata}

      {:error, _} ->
        sleeping_time = min(5000, 1000 * Bitwise.bsl(1, retry_count))
        :timer.sleep(sleeping_time)
        fetch_game_meta_data(platform_id, game_id, retry_count + 1)
    end
  end

  @impl true
  def handle_continue(:start, state) do
    params = %{
      game_id: state.game_id,
      platform_id: state.platform_id,
      encryption_key: state.active_game["observers"]["encryptionKey"]
    }

    with {:ok, version} <- Lor.Lol.Observer.fetch_api_version(state.platform_id),
         {:ok, metadata} <- fetch_game_meta_data(state.platform_id, state.game_id),
         {:ok, replay} <- Lor.Lol.Replay.create(Map.put(params, :metadata, metadata)) do
      send(self(), :record_media_data)
      state = %{state | version: version, metadata: metadata, replay_id: replay.id}
      {:noreply, state}
    else
      {:error, error} ->
        Logger.error("Could not start the replay worker error #{inspect(error)}")
        {:stop, :normal, state}
    end
  end

  @impl true
  def handle_info(:record_media_data, state) do
    Logger.debug("record_media_data")

    case Lor.Lol.Observer.fetch_last_chunk_info(state.platform_id, state.game_id) do
      {:ok, chunk_info} ->
        handle_chunk_info(chunk_info, state)

      {:error, :not_found} ->
        {:stop, :normal, state}
    end
  end

  def handle_info({:process_previous_media_data, chunk_id, key_frame_id}, state) do
    for chunk_id <- 1..(chunk_id - 1) do
      send(self(), {:fetch_and_store_game_data_chunk, chunk_id})
    end

    for key_frame_id <- 1..(key_frame_id - 1) do
      send(self(), {:fetch_and_store_key_frame, key_frame_id})
    end

    {:noreply, state}
  end

  def handle_info({:process_media_data, chunk_id, key_frame_id}, state) do
    send(self(), {:fetch_and_store_game_data_chunk, chunk_id})
    send(self(), {:fetch_and_store_key_frame, key_frame_id})
    {:noreply, state}
  end

  def handle_info({:fetch_and_store_game_data_chunk, chunk_id}, state) do
    Logger.debug("fetch_and_store_game_data_chunk #{chunk_id}")

    case Map.get(state.chunk_statuses, chunk_id, :not_started) do
      :not_started ->
        {:ok, task_pid} =
          Task.Supervisor.start_child(
            Lor.Lol.Replays.TaskSupervisor,
            Lor.Lol.Replays.Download,
            :fetch_and_store_game_data_chunk,
            [
              %{
                worker_pid: self(),
                platform_id: state.platform_id,
                replay_id: state.replay_id,
                game_id: state.game_id,
                chunk_id: chunk_id
              }
            ]
          )

        Process.monitor(task_pid)

        new_state = %{
          state
          | chunk_statuses: Map.put(state.chunk_statuses, chunk_id, :processing),
            tasks: MapSet.put(state.tasks, task_pid)
        }

        {:noreply, new_state}

      status when status in [:processing, :downloaded, :missing] ->
        {:noreply, state}
    end
  end

  def handle_info({:update_chunk_status, chunk_id, status}, state) do
    Logger.debug("update_chunk_status")
    new_state = %{state | chunk_statuses: Map.put(state.chunk_statuses, chunk_id, status)}

    if record_completed?(new_state) do
      {:stop, :normal, new_state}
    else
      {:noreply, new_state}
    end
  end

  def handle_info({:fetch_and_store_key_frame, key_frame_id}, state) do
    Logger.debug("fetch_and_store_key_frame #{key_frame_id}")

    case Map.get(state.key_frame_statuses, key_frame_id, :not_started) do
      :not_started ->
        {:ok, task_pid} =
          Task.Supervisor.start_child(
            Lor.Lol.Replays.TaskSupervisor,
            Lor.Lol.Replays.Download,
            :fetch_and_store_key_frame,
            [
              %{
                worker_pid: self(),
                platform_id: state.platform_id,
                replay_id: state.replay_id,
                game_id: state.game_id,
                key_frame_id: key_frame_id
              }
            ]
          )

        Process.monitor(task_pid)

        new_state = %{
          state
          | key_frame_statuses: Map.put(state.key_frame_statuses, key_frame_id, :processing),
            tasks: MapSet.put(state.tasks, task_pid)
        }

        {:noreply, new_state}

      status when status in [:processing, :downloaded, :missing] ->
        {:noreply, state}
    end
  end

  def handle_info({:update_key_frame_status, key_frame_id, status}, state) do
    Logger.debug("update_key_frame_status")

    new_state = %{
      state
      | key_frame_statuses: Map.put(state.key_frame_statuses, key_frame_id, status)
    }

    if record_completed?(new_state) do
      {:stop, :normal, new_state}
    else
      {:noreply, new_state}
    end
  end

  def handle_info({:DOWN, _ref, :process, task_pid, reason}, state) do
    Logger.debug("received DOWN from task reason #{inspect(reason)}")
    new_tasks = MapSet.delete(state.tasks, task_pid)
    new_state = %{state | tasks: new_tasks}

    if record_completed?(new_state) do
      {:stop, :normal, new_state}
    else
      {:noreply, new_state}
    end
  end

  defp handle_chunk_info(%{"chunkId" => 0, "keyFrameId" => 0}, state) do
    Logger.debug("Game not started yet retry in 20 sec...")
    Process.send_after(self(), :record_media_data, 20_000)
    {:noreply, state}
  end

  defp handle_chunk_info(chunk_info, state) do
    chunk_id = chunk_info["chunkId"]
    key_frame_id = chunk_info["keyFrameId"]
    end_game_chunk_id = chunk_info["endGameChunkId"]

    if chunk_id > state.current_chunk_id do
      Logger.debug("""
        Gap detected between chunk_id and current_chunk_id.
        Try to download previous media data
      """)

      send(self(), {:process_previous_media_data, chunk_id, key_frame_id})
    end

    send(self(), {:process_media_data, chunk_id, key_frame_id})

    if chunk_id == end_game_chunk_id do
      handle_last_chunk(chunk_info, state)
    else
      handle_next_chunk(chunk_info, state)
    end
  end

  defp handle_last_chunk(chunk_info, state) do
    Logger.debug("Received last chunk info terminating...")
    new_state = %{state | chunk_infos: [chunk_info | state.chunk_infos]}

    if record_completed?(state) do
      {:stop, :normal, new_state}
    else
      {:noreply, new_state}
    end
  end

  defp handle_next_chunk(chunk_info, state) do
    chunk_id = chunk_info["chunkId"]
    Logger.debug("Increment current_chunk and wait...")

    Process.send_after(self(), :record_media_data, chunk_info["nextAvailableChunk"])

    state = %{
      state
      | current_chunk_id: chunk_id + 1,
        chunk_infos: [chunk_info | state.chunk_infos]
    }

    {:noreply, state}
  end

  defp record_completed?(
         %{
           current_chunk_id: current_chunk_id,
           chunk_infos: [last_chunk_infos | _],
           chunk_statuses: chunk_statuses,
           key_frame_statuses: key_frame_statuses
         } = state
       ) do
    no_task? = MapSet.size(state.tasks) == 0
    last_chunk_infos? = current_chunk_id == last_chunk_infos["endGameChunkId"]
    chunk_statuses? = Enum.all?(chunk_statuses, &(&1 != :processing))
    key_frames_statuses? = Enum.all?(key_frame_statuses, &(&1 != :processing))

    no_task? and last_chunk_infos? and chunk_statuses? and key_frames_statuses?
  end

  defp record_completed?(_), do: false

  @impl true
  def terminate(reason, state) do
    Logger.info("Replays worker terminate reason: #{inspect(reason)} state: #{inspect(state)}")
    Process.send(state.manager_pid, {:terminating, state}, [])

    # Gracefully stop the GenServer process
    :normal
  end
end
