defmodule GeoTasksWeb.AssignTaskReq do
  @moduledoc false

  use GeoTasksWeb.Req, %{
    task_id: :string
  }

  @required [
    :task_id
  ]

  defp validate(changeset) do
    changeset
    |> validate_required(@required)
    |> validate_length(:task_id, min: 1)
  end
end
