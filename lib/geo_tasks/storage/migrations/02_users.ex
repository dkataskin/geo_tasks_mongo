defmodule GeoTasks.Storage.Migrations.Users do
  @moduledoc false

  defmodule TestUserDataManager do
    @moduledoc false

    @behaviour GeoTasks.Storage.Migration

    alias GeoTasks.{User, UserStorage, AccessToken}

    def id(), do: "02.01_test_user_data_manager"

    def up(_instance, _options) do
      for _ <- 1..20 do
        {:ok, %User{id: id}} =
          %User{
            name: UUID.uuid1(),
            role: :manager
          }
          |> UserStorage.create_new()

        {:ok, access_token} = AccessToken.generate_new()
        {:ok, _} = UserStorage.add_access_token(id, access_token)
      end

      :ok
    end
  end

  defmodule TestUserDataDriver do
    @moduledoc false

    @behaviour GeoTasks.Storage.Migration

    alias GeoTasks.{User, UserStorage, AccessToken}

    def id(), do: "02.02_test_user_data_driver"

    def up(_instance, _options) do
      for _ <- 1..100 do
        {:ok, %User{id: id}} =
          %User{
            name: UUID.uuid1(),
            role: :driver
          }
          |> UserStorage.create_new()

        {:ok, access_token} = AccessToken.generate_new()
        {:ok, _} = UserStorage.add_access_token(id, access_token)
      end

      :ok
    end
  end
end
