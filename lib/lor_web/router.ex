defmodule LorWeb.Router do
  use LorWeb, :router

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

  live_session :default, on_mount: [LorWeb.Hooks.ActivePage] do
    scope "/", LorWeb do
      pipe_through :browser

      live "/", ActiveGameLive.Index, :index
      live "/replays", ReplayLive.Index, :index
      live "/players", PlayerLive.Index, :index
      live "/player/:name", PlayerLive.Show, :index
      get "/script/spectate", ScriptController, :spectate
    end
  end

  live_session :admin, on_mount: [LorWeb.Hooks.ActivePage] do
    scope "/admin", LorWeb do
      pipe_through :admin

      live "/", AdminLive.Index, :index
      live "/teams", AdminLive.Team, :index
      live "/team/new", AdminLive.Team, :new
      live "/team/edit/:team_id", AdminLive.Team, :edit
      live "/players", AdminLive.Player, :index
      live "/player/new", AdminLive.Player, :new
      live "/player/edit/:player_id", AdminLive.Player, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LorWeb do
  #   pipe_through :api
  # end

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
