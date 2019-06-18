defmodule GeoTasks.Config do
  @moduledoc false

  @app :geo_tasks

  @spec get_mongo_opts!() :: Keyword.t()
  def get_mongo_opts!(), do: Application.fetch_env!(@app, :mongo)
end
