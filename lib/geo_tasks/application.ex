defmodule GeoTasks.Application do
  @moduledoc false

  import Supervisor.Spec

  use Application

  alias GeoTasks.Config

  def start(_type, _args) do
    children = [
      GeoTasksWeb.Endpoint,
      worker(Mongo, [Config.get_mongo_opts!()])
    ]

    opts = [strategy: :one_for_one, name: GeoTasks.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    GeoTasksWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
