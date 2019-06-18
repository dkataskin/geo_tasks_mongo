defmodule GeoTasks.Task do
  @moduledoc false

  @enforce_keys [:external_id, :location, :created_at]

  defstruct id: nil,
            external_id: nil,
            location: nil,
            status: :created,
            creator_id: nil,
            assignee_id: nil,
            created_at: nil,
            assigned_at: nil,
            completed_at: nil

  @type location :: %{
          lon: number(),
          lat: number()
        }

  @type task_status :: :created | :assigned | :completed

  @type t :: %__MODULE__{
          id: BSON.ObjectId.t(),
          external_id: String.t(),
          location: location(),
          status: task_status(),
          creator_id: BSON.ObjectId.t(),
          assignee_id: nil | BSON.ObjectId.t(),
          created_at: DateTime.t(),
          assigned_at: nil | DateTime.t(),
          completed_at: nil | DateTime.t()
        }
end
