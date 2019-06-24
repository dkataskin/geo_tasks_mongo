defmodule GeoTasks.StringUtils do
  @moduledoc false

  @spec downcase_safe(nil) :: nil
  def downcase_safe(nil), do: nil

  @spec downcase_safe(binary()) :: binary()
  def downcase_safe(str) when is_binary(str), do: str |> String.downcase()
end
