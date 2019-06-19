defmodule GeoTasks.Task do
  @moduledoc false

  @enforce_keys [:external_id, :pickup_loc, :delivery_loc, :created_at]

  defstruct id: nil,
            ver: 0,
            external_id: nil,
            pickup_loc: nil,
            delivery_loc: nil,
            status: :created,
            creator_id: nil,
            assignee_id: nil,
            created_at: nil,
            assigned_at: nil,
            completed_at: nil

  @type external_id :: String.t()
  @type location :: %{
          lon: number(),
          lat: number()
        }

  @type task_status :: :created | :assigned | :completed

  @type t :: %__MODULE__{
          id: BSON.ObjectId.t(),
          ver: non_neg_integer(),
          external_id: external_id(),
          pickup_loc: location(),
          delivery_loc: location(),
          status: task_status(),
          creator_id: BSON.ObjectId.t(),
          assignee_id: nil | BSON.ObjectId.t(),
          created_at: DateTime.t(),
          assigned_at: nil | DateTime.t(),
          completed_at: nil | DateTime.t()
        }
end
