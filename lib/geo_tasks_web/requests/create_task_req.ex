defmodule GeoTasksWeb.CreateTaskReq do
  @moduledoc false

  import Ecto.Changeset

  alias GeoTasks.{EctoLocation, LocationValidator}

  require Logger

  @required [
    :pickup,
    :delivery
  ]

  @schema %{
    pickup: EctoLocation,
    delivery: EctoLocation
  }

  def parse_validate(params) do
    changeset = params |> cast() |> validate

    if changeset.valid? do
      {:valid, %{pickup: changeset.changes.pickup, delivery: changeset.changes.delivery}}
    else
      {:invalid, changeset}
    end
  end

  def validate(changeset) do
    changeset
    |> validate_required(@required)
    |> LocationValidator.validate(:pickup, message: "pickup location must be specified")
    |> LocationValidator.validate(:delivery, message: "delivery location must be specified")
    |> LocationValidator.validate_match(:pickup, changeset.changes.delivery,
      message: "delivery location must be different from pickup location"
    )
  end

  defp cast(params) do
    data = %{}

    empty_map =
      @schema
      |> Map.keys()
      |> Enum.reduce(%{}, fn key, acc -> Map.put(acc, key, nil) end)

    changeset = {data, @schema} |> Ecto.Changeset.cast(params, Map.keys(@schema))

    put_in(changeset.changes, Map.merge(empty_map, changeset.changes))
  end
end
