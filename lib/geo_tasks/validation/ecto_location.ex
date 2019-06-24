defmodule GeoTasks.EctoLocation do
  @moduledoc false

  @behaviour Ecto.Type

  def type(), do: :string

  def cast(location) when is_binary(location) do
    {:ok, parse_location(location)}
  end

  def cast(%{lon: _lon, lat: _lat} = location), do: {:ok, location}

  def cast(_), do: :error

  def load(%{lon: _lon, lat: _lat} = location) do
    {:ok, location}
  end

  def dump(%{lon: _lon, lat: _lat} = location), do: {:ok, location}
  def dump(_), do: :error

  defp parse_location(nil), do: nil

  defp parse_location(location_str) when is_binary(location_str) do
    case location_str |> String.split(",") do
      [lon_str, lat_str] ->
        %{
          lon: parse_float(lon_str),
          lat: parse_float(lat_str)
        }

      _ ->
        nil
    end
  end

  defp parse_float(nil), do: nil

  defp parse_float(float_str) when is_binary(float_str) do
    with {float, _} <- Float.parse(float_str) do
      float
    else
      :error ->
        nil
    end
  end
end
