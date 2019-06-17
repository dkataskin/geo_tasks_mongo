defmodule GeoTasks.MixProject do
  use Mix.Project

  def project do
    [
      app: :geo_tasks,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {GeoTasks.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4.7"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:logger_file_backend, "~> 0.0.10"},
      {:credo, "~> 1.0.5", only: [:dev, :test], runtime: false},
      {:retry, "~> 0.10.0"},
      {:mongodb, "~> 0.5.1"}
    ]
  end
end
