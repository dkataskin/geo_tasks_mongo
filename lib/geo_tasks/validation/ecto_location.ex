defmodule GeoTasks.EctoLocation do
  @moduledoc false

  @behaviour Ecto.Type

  alias GeoTasks.Task

  @spec type() :: atom()
  def type(), do: :string

  @spec cast(String.t()) :: {:ok, Task.location()}
  def cast(location) when is_binary(location) do
    {:ok, parse_location(location)}
  end

  @spec cast(Map.t()) :: {:ok, Task.location()}
  def cast(location) when is_map(location) do
    {:ok, parse_location(location)}
  end

  @spec cast(Task.location()) :: {:ok, Task.location()}
  def cast(%{lon: _lon, lat: _lat} = location), do: {:ok, location}

  @spec cast(any()) :: {:error}
  def cast(_), do: :error

  @spec cast(Task.location()) :: {:ok, Task.location()}
  def load(%{lon: _lon, lat: _lat} = location) do
    {:ok, location}
  end

  @spec dump(Task.location()) :: {:ok, Task.location()}
  def dump(%{lon: _lon, lat: _lat} = location), do: {:ok, location}

  @spec dump(any()) :: :error
  def dump(_), do: :error

  @spec parse_location(nil) :: nil
  defp parse_location(nil), do: nil

  @spec parse_location(String.t()) :: Task.location()
  defp parse_location(location_str) when is_binary(location_str) do
    case location_str |> String.split(",") do
      [lon_str, lat_str] ->
        %{
          lon: parse_number(lon_str),
          lat: parse_number(lat_str)
        }

      _ ->
        nil
    end
  end

  @spec parse_location(Map.t()) :: Task.location()
  defp parse_location(%{} = map) do
    %{
      lon: map |> Map.get("lon") |> parse_number(),
      lat: map |> Map.get("lat") |> parse_number()
    }
  end

  @spec parse_number(nil) :: nil
  defp parse_number(nil), do: nil

  @spec parse_number(number()) :: number()
  defp parse_number(number) when is_number(number), do: number

  @spec parse_number(String.t()) :: nil | float()
  defp parse_number(number_str) when is_binary(number_str) do
    with {float, _} <- Float.parse(number_str) do
      float
    else
      :error ->
        nil
    end
  end
end
