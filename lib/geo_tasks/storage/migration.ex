defmodule GeoTasks.Storage.Migration do
  @moduledoc """
  Base behaviour for a mongodb migration
  """

  @callback id() :: String.t()
  @callback up(atom, Keyword.t()) :: :ok
end
