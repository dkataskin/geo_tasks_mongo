defmodule GeoTasks.Task do
  @moduledoc false

  defstruct id: nil,
            external_id: nil,
            lon: nil,
            lat: nil,
            status: :created,
            assignee_id: nil,
            created_at: nil,
            assigned_at: nil,
            completed_at: nil

  @type task_status :: :created | :assigned | :completed
  @type t :: %__MODULE__{
    id: BSON.ObjectId,
    external_id: String.t(),
    lat: float(),
    lon: float(),
    status: task_status(),
    assignee_id: BSON.ObjectId,
    created_at: DateTime.t(),
    assigned_at: DateTime.t(),
    completed_at: DateTime.t()
  }
end