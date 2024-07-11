defmodule Lor.MixProject do
  use Mix.Project

  def project do
    [
      app: :lor,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Lor.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/fixture"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ash, "== 2.19.14"},
      {:ash_json_api, "== 0.34.2"},
      {:ash_oban, "== 0.1.14"},
      {:ash_phoenix, "== 1.3.4"},
      {:ash_postgres, "== 1.5.19"},
      {:ash_state_machine, "== 0.2.2"},
      {:open_api_spex, "== 3.18.3"},
      {:aws, "== 0.13.3"},
      {:ecto_sql, "== 3.11.1"},
      {:floki, "== 0.36.1"},
      {:gettext, "== 0.20.0"},
      {:hackney, "== 1.20.1"},
      {:jason, "== 1.4.1"},
      {:libcluster, "== 3.3.3"},
      {:nebulex, "== 2.6.1"},
      {:petal_components, "== 1.9.2"},
      {:phoenix, "== 1.7.11"},
      {:phoenix_ecto, "== 4.5.1"},
      {:phoenix_html, "== 4.1.1"},
      {:phoenix_live_dashboard, "== 0.8.3"},
      {:phoenix_live_view, "== 0.20.14"},
      {:plug_cowboy, "== 2.7.0"},
      {:postgrex, "== 0.17.5"},
      {:reactor, "== 0.4.1"},
      {:swoosh, "== 1.16.3"},
      {:telemetry_metrics, "== 0.6.2"},
      {:telemetry_poller, "== 1.0.0"},
      {:tesla, "== 1.8.0"},
      {:esbuild, "== 0.8.1", runtime: Mix.env() == :dev},
      {:exvcr, "== 0.15.1", only: :test},
      {:phoenix_live_reload, "== 1.5.2", only: :dev},
      {:tailwind, "== 0.2.2", runtime: Mix.env() == :dev},
      {:tailwind_formatter, "== 0.4.0", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      "esbuild.meta": ["esbuild default --minify --metafile=meta.json"],
      "format.all": ["format", "cmd npm run format --prefix ./assets"],
      "format.check": ["format --check-formatted", "cmd npm run format-check --prefix ./assets"]
    ]
  end
end
