defmodule GeoTasks.TaskFactory do
  @moduledoc false

  alias GeoTasks.Task

  def gen_new_task() do
    %Task{
      id: nil,
      external_id: UUID.uuid1(),
      location: gen_location(),
      status: :created,
      assignee_id: nil,
      created_at: DateTime.utc_now() |> DateTime.truncate(:millisecond)
    }
  end

  def gen_location() do
    %{
      lon: :rand.uniform() * 360 - 180,
      lat: :rand.uniform() * 180 - 90
    }
  end
end
