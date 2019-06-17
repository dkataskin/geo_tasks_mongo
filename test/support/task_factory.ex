defmodule GeoTasks.TaskFactory do
  alias GeoTasks.Task

  def gen_new_task() do
    %Task{
      id: nil,
      external_id: UUID.uuid1(),
      lon: :rand.uniform(360) - 180,
      lat: :rand.uniform(180) - 90,
      status: :created,
      assignee_id: nil,
      created_at: DateTime.utc_now()
    }
  end
end