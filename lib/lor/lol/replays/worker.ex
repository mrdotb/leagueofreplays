defmodule Lor.Lol.Replays.Worker do
  @moduledoc """
  Worker GenServer to download the replays file
  """
  use GenServer, restart: :temporary

  require Logger

  defstruct ~w(
    id manager_pid platform_id game_id replay_id
    encryption_key replay
    client version current_chunk_id last_chunk_info
    chunk_statuses key_frame_statuses tasks
    error
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
      game_id: args.game_id,
      encryption_key: args.encryption_key,
      current_chunk_id: 1,
      chunk_statuses: %{},
      key_frame_statuses: %{},
      tasks: MapSet.new()
    }

    # Makes the process call terminate/2 upon exit.
    Process.flag(:trap_exit, true)

    {:ok, state, {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    params = %{
      game_id: state.game_id,
      platform_id: state.platform_id,
      encryption_key: state.encryption_key
    }

    with {:ok, version} <- Lor.Lol.Observer.fetch_api_version(state.platform_id),
         {:ok, metadata} <-
           Lor.Lol.Observer.fetch_game_meta_data(state.platform_id, state.game_id),
         {:ok, replay} <- Lor.Lol.Replay.create(Map.put(params, :game_meta_data, metadata)) do
      send(self(), :record_media_data)
      state = %{state | version: version, replay: replay, replay_id: replay.id}
      {:noreply, state}
    else
      {:error, error} ->
        Logger.error("Could not start the replay worker error #{inspect(error)}")
        state = %{state | error: error}
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
        state = %{state | error: :not_found}
        {:stop, :normal, state}
    end
  end

  def handle_info({:process_previous_media_data, chunk_id, key_frame_id}, state) do
    for chunk_id <- 1..(chunk_id - 1), chunk_id > 0 do
      send(self(), {:fetch_and_store_game_data_chunk, chunk_id})
    end

    for key_frame_id <- 1..(key_frame_id - 1), key_frame_id > 0 do
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

  @impl true
  def terminate(:normal, %{error: nil} = state) do
    Logger.info("Replays worker normal terminate state: #{inspect(state, pretty: true)}")

    params = %{
      first_chunk_id: get_first_chunk_id(state.chunk_statuses),
      last_chunk_id: get_last_chunk_id(state.chunk_statuses),
      first_key_frame_id: get_first_key_frame_id(state.key_frame_statuses),
      last_key_frame_id: get_last_key_frame_id(state.key_frame_statuses)
    }

    Lor.Lol.Replay.finish(state.replay, params)

    Process.send(state.manager_pid, {:terminating, state}, [])

    # Gracefully stop the GenServer process
    :normal
  end

  def terminate(:normal, %{error: error} = state) do
    Logger.info(
      "Replays worker error terminate error: #{inspect(error)} state: #{inspect(state, pretty: true)}"
    )

    Process.send(state.manager_pid, {:terminating, state}, [])

    # Gracefully stop the GenServer process
    :normal
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
    new_state = %{state | last_chunk_info: chunk_info}

    if record_completed?(state) do
      {:stop, :normal, new_state}
    else
      {:noreply, new_state}
    end
  end

  defp handle_next_chunk(chunk_info, state) do
    chunk_id = chunk_info["chunkId"]
    Logger.debug("Increment current_chunk and wait...")

    time =
      if(chunk_info["nextAvailableChunk"] == 0,
        do: 10_000,
        else: chunk_info["nextAvailableChunk"]
      )

    Process.send_after(self(), :record_media_data, time)

    state = %{
      state
      | current_chunk_id: chunk_id + 1,
        last_chunk_info: chunk_info
    }

    {:noreply, state}
  end

  defp record_completed?(
         %{
           last_chunk_info: last_chunk_info,
           chunk_statuses: chunk_statuses,
           key_frame_statuses: key_frame_statuses
         } = state
       ) do
    no_tasks? = MapSet.size(state.tasks) == 0
    last_chunk_info? = last_chunk_info["chunkId"] == last_chunk_info["endGameChunkId"]
    chunk_statuses? = Enum.all?(chunk_statuses, &(&1 != :processing))
    key_frame_statuses? = Enum.all?(key_frame_statuses, &(&1 != :processing))

    no_tasks? and last_chunk_info? and chunk_statuses? and key_frame_statuses?
  end

  defp record_completed?(_), do: false

  defp get_first_chunk_id(chunk_statuses) do
    chunk_statuses
    |> Enum.filter(fn {id, status} ->
      # Chunk 1 and 2 can always be downloaded
      status == :downloaded and id > 2
    end)
    |> Enum.map(fn {id, _} -> id end)
    |> Enum.min()
  end

  def find_first_of_range([last]), do: last
  def find_first_of_range([a, b | c]) when a - b == 1, do: find_first_of_range([b | c])
  def find_first_of_range([a, _ | _]), do: a

  defp get_last_chunk_id(chunk_statuses) do
    chunk_statuses
    |> Enum.filter(fn {_id, status} ->
      status == :downloaded
    end)
    |> Enum.map(fn {id, _} -> id end)
    |> Enum.max()
  end

  defp get_first_key_frame_id(key_frame_statuses) do
    key_frame_statuses
    |> Enum.filter(fn {_id, status} ->
      status == :downloaded
    end)
    |> Enum.map(fn {id, _} -> id end)
    |> Enum.min()
  end

  defp get_last_key_frame_id(key_frame_statuses) do
    key_frame_statuses
    |> Enum.filter(fn {_id, status} ->
      status == :downloaded
    end)
    |> Enum.map(fn {id, _} -> id end)
    |> Enum.max()
  end
end
