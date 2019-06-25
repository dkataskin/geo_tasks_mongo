defmodule GeoTasks.TaskStorage do
  @moduledoc false

  import GeoTasks.MongoMapUtils, only: [map_id!: 2]

  alias GeoTasks.Task
  alias GeoTasks.MongoDB

  require Logger

  @coll "tasks"

  @type single_task_result :: {:ok, nil} | {:ok, Task.t()} | {:error, any()}

  @spec create_new(Task.t()) :: single_task_result()
  def create_new(%Task{id: nil} = task) do
    with {:ok, id} <- MongoDB.insert_one(@coll, map_to_db(task)) do
      {:ok, %Task{task | id: id}}
    else
      error ->
        Logger.error("An error occurred while inserting a new task: #{inspect(error)}")
        error
    end
  end

  @spec list(Task.location(), pos_integer(), pos_integer()) :: {:ok, [Task.t()]} | {:error, any()}
  def list(%{lon: lon, lat: lat} = location, max_distance \\ nil, limit \\ 100)
      when is_number(limit) and is_number(max_distance) do
    near_sphere =
      %{
        "$geometry" => %{
          "type" => "Point",
          "coordinates" => [lon, lat]
        }
      }
      |> append_max_distance_limit(max_distance)

    filter = %{
      "status" => :created,
      "pickup_loc" => %{
        "$nearSphere" => near_sphere
      }
    }

    opts = [map_fn: &map_from_db/1, limit: limit]

    with {:error, reason} <- MongoDB.find(@coll, filter, opts) do
      Logger.error(
        "An error occurred while fetching tasks for location #{inspect(location)}, max distance: #{
          inspect(max_distance)
        }: #{inspect(reason)}"
      )

      {:error, reason}
    else
      list when is_list(list) ->
        {:ok, list}
    end
  end

  @spec get_by_external_id(String.t()) :: single_task_result()
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

  @spec update(Task.t(), Map.t()) :: single_task_result()
  def update(%Task{id: id, ver: ver}, %{} = updates) do
    filter = %{
      "_id" => id,
      "ver" => ver
    }

    update = %{
      "$set" =>
        updates
        |> Enum.reduce(Map.new(), fn {key, value}, acc ->
          acc |> Map.put(key |> to_string(), value)
        end),
      "$inc" => %{
        "ver" => 1
      }
    }

    opts = [map_fn: &map_from_db/1, return_document: :after]
    MongoDB.find_one_and_update(@coll, filter, update, opts)
  end

  def set_status(%Task{} = task, :assigned, %BSON.ObjectId{} = user_id) do
    updates = %{
      status: :assigned,
      assign_lock: user_id,
      assignee_id: user_id,
      assigned_at: task.assigned_at || DateTime.utc_now()
    }

    update(task, updates)
  end

  def set_status(%Task{} = task, :completed) do
    updates = %{
      status: :completed,
      assign_lock: task.external_id,
      completed_at: task.completed_at || DateTime.utc_now()
    }

    update(task, updates)
  end

  @spec map_to_db(Task.t()) :: BSON.document()
  defp map_to_db(%Task{id: id, ver: ver} = task) do
    %{
      "external_id" => task.external_id,
      "ver" => ver,
      "pickup_loc" => map_location_to_db(task.pickup_loc),
      "delivery_loc" => map_location_to_db(task.delivery_loc),
      "assign_lock" => task.external_id,
      "status" => task.status |> to_string(),
      "assignee_id" => task.assignee_id,
      "created_at" => task.created_at || DateTime.utc_now(),
      "assigned_at" => task.assigned_at,
      "completed_at" => task.completed_at
    }
    |> map_id!(id)
  end

  @spec map_to_db(nil) :: nil
  defp map_from_db(nil), do: nil

  @spec map_to_db(BSON.document()) :: Task.t()
  defp map_from_db(%{"_id" => id, "ver" => ver} = doc) do
    %Task{
      id: id,
      ver: ver,
      external_id: doc["external_id"],
      pickup_loc: map_location_from_db(doc["pickup_loc"]),
      delivery_loc: map_location_from_db(doc["delivery_loc"]),
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

  @spec append_max_distance_limit(BSON.document(), nil | pos_integer()) :: BSON.document()
  defp append_max_distance_limit(query, nil), do: query

  defp append_max_distance_limit(query, max_distance) do
    query |> Map.put("$maxDistance", max_distance)
  end
end
