defmodule GeoTasks.LocationValidator do
  @moduledoc false

  import Ecto.Changeset

  def validate_match(changeset, field, location, options \\ [])

  def validate_match(changeset, field, %{lon: lon1, lat: lat1}, options) do
    validate_change(changeset, field, fn _, %{lon: lon2, lat: lat2} ->
      if lon1 == lon2 and lat1 == lat2 do
        [{field, options[:message] || "locations must not match"}]
      else
        []
      end
    end)
  end

  def validate_match(changeset, _field, _, _options), do: changeset

  def validate(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, %{lon: lon, lat: lat} ->
      []
      |> validate_lon(lon, field, options)
      |> validate_lat(lat, field, options)
    end)
  end

  defp validate_lon(errors, nil, field, options),
    do: [{field, options[:message] || "Longitude must not be empty"} | errors]

  defp validate_lon(errors, lon, field, options) do
    if lon >= -180 and lon <= 180 do
      errors
    else
      message = options[:message] || "Longitude value must be between -180 and 180 both inclusive"
      [{field, message} | errors]
    end
  end

  defp validate_lat(errors, nil, field, options),
    do: [{field, options[:message] || "Latitude must not be empty"} | errors]

  defp validate_lat(errors, lat, field, options) do
    if lat >= -90 and lat <= 90 do
      errors
    else
      message = options[:message] || "Latitude value must be between -180 and 180 both inclusive"
      [{field, message} | errors]
    end
  end
end
