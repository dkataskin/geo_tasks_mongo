defmodule GeoTasks.AccessTokenTest do
  @moduledoc false

  use ExUnit.Case

  alias GeoTasks.AccessToken

  test "can generate a new token" do
    result = AccessToken.generate_new()
    assert result
    assert elem(result, 0) == :ok

    {:ok, access_token} = result
    assert is_binary(access_token)
    assert String.length(access_token) > 0
  end
end