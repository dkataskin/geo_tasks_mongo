defmodule GeoTasks.TaskStorage do
  @moduledoc false

  import GeoTasks.MongoMapUtils, only: [map_id!: 2]

  alias GeoTasks.Task
  alias GeoTasks.MongoDB

  require Logger

  @coll "tasks"

  @type singe_task_result :: {:ok, Task.t()} | {:error, any()}

  @spec create_new(Task.t()) :: singe_task_result()
  def create_new(%Task{id: nil} = task) do
    with {:ok, id} <- MongoDB.insert_one(@coll, map_to_db(task)) do
      {:ok, %Task{task | id: id}}
    else
      error ->
        Logger.error("An error occurred while inserting a new task: #{inspect(error)}")
        error
    end
  end

  @spec get_by_external_id(String.t()) :: singe_task_result()
  def get_by_external_id(external_id) when is_binary(external_id) do
    with {:ok, task} <-
           MongoDB.find_one(@coll, %{"external_id" => external_id}, map_fn: &map_from_db/1) do
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

  @spec map_to_db(Task.t()) :: BSON.document()
  defp map_to_db(%Task{id: id, location: location} = task) do
    %{
      "external_id" => task.external_id,
      "location" => map_location_to_db(location),
      "status" => task.status |> to_string(),
      "assignee_id" => task.assignee_id,
      "created_at" => task.created_at,
      "assigned_at" => task.assigned_at,
      "completed_at" => task.completed_at
    }
    |> map_id!(id)
  end

  @spec map_to_db(nil) :: nil
  defp map_from_db(nil), do: nil

  @spec map_to_db(BSON.document()) :: Task.t()
  defp map_from_db(%{"_id" => id, "location" => location} = doc) do
    %Task{
      id: id,
      external_id: doc["external_id"],
      location: map_location_from_db(location),
      status: (doc["status"] || "created") |> String.to_atom(),
      assignee_id: doc["assignee_id"],
      created_at: doc["created_at"],
      assigned_at: doc["assigned_at"],
      completed_at: doc["completed_at"]
    }
  end

  @spec map_location_to_db(nil) :: nil
  defp map_location_to_db(nil), do: nil

  @spec map_location_to_db(Task.location()) :: BSON.document()
  defp map_location_to_db(%{lon: lon, lat: lat}) do
    %{
      "type" => "Point",
      "coordinates" => [lon, lat]
    }
  end

  @spec map_location_from_db(nil) :: nil
  defp map_location_from_db(nil), do: nil

  @spec map_location_from_db(BSON.document()) :: Task.location()
  defp map_location_from_db(%{"type" => "Point", "coordinates" => [lon, lat]}) do
    %{
      lon: lon,
      lat: lat
    }
  end
end
