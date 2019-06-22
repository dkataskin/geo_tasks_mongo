defmodule GeoTasks.Storage.Migrations.Indexes do
  @moduledoc false

  defmodule UserCollIndexes do
    @moduledoc false

    @behaviour GeoTasks.Storage.Migration

    def id(), do: "01.01_ensure_indexes_user_coll"

    def up(instance, options) do
      query = %{
        createIndexes: "users",
        indexes: [
          %{key: %{name: 1}, name: "name_1"},
          %{key: %{access_tokens: 1}, name: "access_tokens_1"}
        ]
      }

      {:ok, _} = Mongo.command(instance, query, options)
      :ok
    end
  end

  defmodule TaskCollIndexes do
    @moduledoc false

    @behaviour GeoTasks.Storage.Migration

    def id(), do: "01.02_ensure_indexes_tasks_coll"

    def up(instance, options) do
      query = %{
        createIndexes: "tasks",
        indexes: [
          %{key: %{assign_lock: 1}, unique: true, name: "assign_lock_unique_1"},
          %{key: %{assignee_id: 1}, name: "assignee_id_1"},
          %{key: %{assigned_at: 1}, name: "assigned_at_1"},
          %{key: %{creator_id: 1}, name: "creator_id_1"},
          %{key: %{created_at: 1}, name: "created_at_1"},
          %{key: %{pickup_loc: :"2dsphere"}, name: "pickup_location"},
          %{key: %{delivery_loc: :"2dsphere"}, name: "delivery_location"}
        ]
      }

      {:ok, _} = Mongo.command(instance, query, options)
      :ok
    end
  end
end
