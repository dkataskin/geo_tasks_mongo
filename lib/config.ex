defmodule GeoTasks.Config do
  @moduledoc false

  @app :geo_tasks

  def get_mongo_opts!(), do: Application.fetch_env!(@app, :mongo)
end
