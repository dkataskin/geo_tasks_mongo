defmodule GeoTasksWeb.TaskView do
  use GeoTasksWeb, :view

  def render("task.json", %{task: task}) do
    %{
      success: true,
      data: %{
        id: task.external_id,
        pickup: task.pickup_loc,
        delivery: task.delivery_loc,
        created: task.created_at
      }
    }
  end

  def render("errors.json", %{errors: errors}) do
    %{
      success: false,
      errors: %{}
    }
  end
end
