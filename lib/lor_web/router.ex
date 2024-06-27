defmodule LorWeb.Router do
  use LorWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug LorWeb.BasicAuthPlug, :admin_dashboard
    plug :browser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LorWeb do
    pipe_through :browser

    live_session :default, on_mount: [LorWeb.Hooks.ActivePage, LorWeb.Hooks.GameVersion] do
      live "/", ActiveGameLive.Index, :index
      live "/replays", ReplayLive.Index, :index
      live "/players", PlayerLive.Index, :index
      live "/players/:name", PlayerLive.Show, :index
      live "/players/:player_id/summoners", SummonerLive.Index, :index
    end

    get "/script/spectate", ScriptController, :spectate
  end

  scope "/admin", LorWeb do
    pipe_through :admin

    live_session :admin, on_mount: [LorWeb.Hooks.ActivePage, LorWeb.Hooks.GameVersion] do
      live "/", AdminLive.Index, :index
      live "/delete-replays", AdminLive.DeleteReplays, :index
      live "/teams", AdminLive.Teams, :index
      live "/teams/new", AdminLive.Teams, :new
      live "/teams/edit/:team_id", AdminLive.Teams, :edit
      live "/players", AdminLive.Players, :index
      live "/players/new", AdminLive.Players, :new
      live "/players/edit/:player_id", AdminLive.Players, :edit
      live "/players/:player_id/summoners", AdminLive.Summoners, :index
      live "/players/:player_id/summoners/attach", AdminLive.Summoners, :attach
    end

    live_dashboard "/dashboard"
  end

  forward "/api/swaggerui",
          OpenApiSpex.Plug.SwaggerUI,
          path: "/api/lol/open_api",
          title: "LOR's JSON-API - Swagger UI",
          default_model_expand_depth: 4

  forward "/api/lol", Lor.Lol.Router
  # forward "/api/pros", Lor.Pros.Router

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:lor, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    # import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      # live_dashboard "/dashboard", metrics: LorWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
