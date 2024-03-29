defmodule GeoTasksWeb.TaskView do
  use GeoTasksWeb, :view

  def render("tasks.json", %{tasks: tasks}) when is_list(tasks) do
    %{
      success: true,
      data: tasks |> Enum.map(&render("task.json", task: &1))
    }
  end

  def render("task.json", %{task: task}) do
    %{
      success: true,
      data: %{
        id: task.external_id,
        status: task.status,
        pickup: task.pickup_loc,
        delivery: task.delivery_loc,
        created: task.created_at
      }
    }
  end
end
