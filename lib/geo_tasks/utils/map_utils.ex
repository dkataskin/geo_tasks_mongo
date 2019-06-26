defmodule GeoTasks.MapUtils do
  @moduledoc false

  @spec atomize_keys(nil) :: nil
  def atomize_keys(nil), do: nil

  @spec atomize_keys(Map.t()) :: Map.t()
  def atomize_keys(%{} = map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), atomize_keys(v)} end)
    |> Enum.into(%{})
  end

  @spec atomize_keys([any]) :: [any]
  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  @spec atomize_keys(any) :: any
  def atomize_keys(not_a_map) do
    not_a_map
  end
end
