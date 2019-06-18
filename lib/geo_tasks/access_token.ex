defmodule GeoTasks.AccessToken do
  @moduledoc false

  @token_length 20

  @type access_token :: String.t()

  @spec generate_new() :: {:ok, access_token}
  def generate_new() do
    {:ok,
     @token_length
     |> :crypto.strong_rand_bytes()
     |> Base.encode16(case: :lower)}
  end
end
