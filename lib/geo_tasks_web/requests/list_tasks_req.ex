defmodule GeoTasksWeb.ListTasksReq do
  @moduledoc false

  use GeoTasksWeb.Req, %{
    location: GeoTasks.EctoLocation,
    max_distance: :integer,
    limit: :integer
  }

  alias GeoTasks.LocationValidator

  @required [
    :location
  ]

  defp validate(changeset) do
    changeset
    |> validate_required(@required)
    |> validate_number(:max_distance, greater_than: 0)
    |> validate_number(:limit, greater_than: 0, less_than_or_equal_to: 100)
    |> LocationValidator.validate(:location, "location is not specified or is invalid")
  end
end
