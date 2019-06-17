defmodule GeoTasks.TaskStorage do
  @moduledoc false

  alias GeoTasks.Task
  alias GeoTasks.MongoDB

  require Logger

  @coll "tasks"

  def create_new(%Task{id: nil} = task) do
    with {:ok, id} <- MongoDB.insert_one(@coll, map_to_db!(task)) do
      {:ok, %Task{task | id: id}}
    else
      error ->
        Logger.error("An error occurred while inserting a new task: #{inspect(error)}")
        error
    end
  end

  def get_by_external_id(external_id) when is_binary(external_id) do
    with {:ok, task} <-
           MongoDB.find_one(@coll, %{"external_id" => external_id}, map_fn: &map_from_db!/1) do
      {:ok, task}
    else
      error ->
        Logger.error(
          "An error occurred while reading task by external id #{external_id} from db: #{
            inspect(error)
          }"
        )

        error
    end
  end

  defp map_to_db!(%Task{id: id, lon: lon, lat: lat} = task) do
    %{
      "_id" => id,
      "external_id" => task.external_id,
      "location" => map_location_to_db!(lon, lat),
      "status" => task.status |> to_string(),
      "assignee_id" => task.assignee_id,
      "created_at" => task.created_at,
      "assigned_at" => task.assigned_at,
      "completed_at" => task.completed_at
    }
  end

  defp map_from_db!(nil), do: nil

  defp map_from_db!(%{"_id" => id, "location" => location} = doc) do
    %{lon: lon, lat: lat} = map_location_from_db!(location)

    %Task{
      id: id,
      external_id: doc["external_id"],
      lon: lon,
      lat: lat,
      status: (doc["status"] || "created") |> String.to_atom(),
      assignee_id: doc["assignee_id"],
      created_at: doc["created_at"],
      assigned_at: doc["assigned_at"],
      completed_at: doc["completed_at"]
    }
  end

  defp map_location_to_db!(nil, _lat), do: nil
  defp map_location_to_db!(_lon, nil), do: nil

  defp map_location_to_db!(lon, lat) do
    %{
      "type" => "Point",
      "coordinates" => [lon, lat]
    }
  end

  defp map_location_from_db!(nil), do: %{lon: nil, lat: nil}

  defp map_location_from_db!(%{"type" => "Point", "coordinates" => [lon, lat]}) do
    %{
      lon: lon,
      lat: lat
    }
  end
end
