defmodule GeoTasksWeb.CreateTaskReq do
  @moduledoc false

  use GeoTasksWeb.Req, %{
    pickup: GeoTasks.EctoLocation,
    delivery: GeoTasks.EctoLocation
  }

  @required [
    :pickup,
    :delivery
  ]

  alias GeoTasks.LocationValidator

  defp validate(changeset) do
    changeset
    |> validate_required(@required)
    |> LocationValidator.validate(:pickup,
      message: "pickup location is not specified or is invalid"
    )
    |> LocationValidator.validate(:delivery,
      message: "delivery location is not specified or is invalid"
    )
    |> LocationValidator.validate_match(:pickup, changeset.changes.delivery,
      message: "delivery location must be different from pickup location"
    )
  end
end
