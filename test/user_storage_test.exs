defmodule GeoTasks.UserStorageTest do
  @moduledoc false

  use ExUnit.Case

  alias GeoTasks.User
  alias GeoTasks.UserStorage
  alias GeoTasks.TestDataFactory
  alias GeoTasks.AccessToken

  def setup do
    cleanup_data()

    on_exit(&cleanup_data/0)
  end

  test "can create a new driver user" do
    user = TestDataFactory.gen_new_user(:driver)
    result = UserStorage.create_new(user)
    assert elem(result, 0) == :ok
    user = elem(result, 1)
    assert user
    assert user.id
  end

  test "can create a new manager user" do
    user = TestDataFactory.gen_new_user(:manager)
    result = UserStorage.create_new(user)
    assert elem(result, 0) == :ok
    user = elem(result, 1)
    assert user
    assert user.id
  end

  test "can get a user by id" do
    {:ok, %User{id: id} = user1} =
      TestDataFactory.gen_new_user()
      |> UserStorage.create_new()

    {:ok, user2} = UserStorage.get_by_id(id)
    assert user2
    assert user1 == user2
  end

  test "can add access token" do
    {:ok, %User{id: id}} =
      TestDataFactory.gen_new_user()
      |> UserStorage.create_new()

    {:ok, access_token} = AccessToken.generate_new()
    assert {:ok, :added} == UserStorage.add_access_token(id, access_token)
  end

  test "can add access token twice" do
    {:ok, %User{id: id}} = TestDataFactory.gen_new_user() |> UserStorage.create_new()

    {:ok, access_token} = AccessToken.generate_new()
    {:ok, :added} = UserStorage.add_access_token(id, access_token)

    assert {:ok, :added} == UserStorage.add_access_token(id, access_token)
  end

  test "can find a user by access token" do
    {:ok, %User{id: id} = user1} =
      TestDataFactory.gen_new_user()
      |> UserStorage.create_new()

    {:ok, access_token} = AccessToken.generate_new()
    {:ok, :added} = UserStorage.add_access_token(id, access_token)

    {:ok, user2} = UserStorage.get_by_access_token(access_token)
    assert user2 == user1
  end

  defp cleanup_data() do
    GeoTasks.MongoDB.delete_many("users", %{})
  end
end
