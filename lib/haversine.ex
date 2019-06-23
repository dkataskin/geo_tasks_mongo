defmodule GeoTasks.Haversine do
  @moduledoc false

  @v :math.pi() / 180

  # earh radius in km
  @r 6372.8

  def distance(%{lon: lon1, lat: lat1}, %{lon: lon2, lat: lat2}) do
    dlat = :math.sin((lat2 - lat1) * @v / 2)
    dlon = :math.sin((lon2 - lon1) * @v / 2)
    a = dlat * dlat + dlon * dlon * :math.cos(lat1 * @v) * :math.cos(lat2 * @v)
    @r * 2 * :math.asin(:math.sqrt(a))
  end
end
