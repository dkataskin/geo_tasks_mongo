defmodule GeoTasks.Application do
  @moduledoc false

  import Supervisor.Spec

  use Application

  alias GeoTasks.Config
  alias GeoTasks.Storage.Migrator

  def start(_type, _args) do
    <<i1::unsigned-integer-32, i2::unsigned-integer-32, i3::unsigned-integer-32>> =
      :crypto.strong_rand_bytes(12)

    :rand.seed(:exsplus, {i1, i2, i3})

    mongo_opts = Config.get_mongo_opts!()

    children = [
      GeoTasksWeb.Endpoint,
      worker(Mongo, [mongo_opts])
    ]

    opts = [strategy: :one_for_one, name: GeoTasks.Supervisor]
    result = Supervisor.start_link(children, opts)

    apply_migrations(mongo_opts)

    result
  end

  def config_change(changed, _new, removed) do
    GeoTasksWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp apply_migrations(mongo_opts), do: Migrator.up(:mongo, mongo_opts)
end
