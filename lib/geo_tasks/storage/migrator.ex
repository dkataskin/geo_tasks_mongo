defmodule GeoTasks.Storage.Migrator do
  @moduledoc false

  require Logger

  @migration_coll "__migrations"

  def up(instance, options) do
    {:ok, :ensured} = ensure_collection_exists(instance, options)
    {:ok, :ensured} = ensure_collection_indexes(instance, options)
    Logger.info("ensured migrations collection exists...")

    migrations =
      get_migration_mods()
      |> Enum.map(&{apply(&1, :id, []), &1})
      |> Map.new()

    ids =
      migrations
      |> Map.keys()
      |> filter_applied(instance, options)

    if length(ids) > 0 do
      Logger.info("found not applied migrations: #{inspect(ids)}")

      for id <- ids |> Enum.sort() do
        :ok = apply(migrations[id], :up, [instance, options])
        {:ok, :marked} = mark_applied(id, instance, options)

        Logger.info("applied #{id} migration")
      end
    else
      Logger.info("all migrations applied, nothing to do")
    end
  end

  def safe_drop_result({:ok, _}), do: :ok
  def safe_drop_result({:error, %Mongo.Error{code: 26}}), do: :ok
  def safe_drop_result({:error, error}), do: {:error, error}

  defp get_migration_mods() do
    {:ok, list} = :application.get_key(:geo_tasks, :modules)

    list
    |> Enum.filter(fn mod ->
      segments = mod |> Module.split()

      length(segments) == 5 &&
        segments |> Enum.take(3) == ~w|GeoTasks Storage Migrations|
    end)
  end

  defp ensure_collection_exists(instance, options) do
    case Mongo.command(instance, %{create: @migration_coll}, options) do
      {:ok, _} ->
        {:ok, :ensured}

      {:error, %Mongo.Error{code: 48}} ->
        {:ok, :ensured}

      {:error, error} ->
        {:error, error}
    end
  end

  defp ensure_collection_indexes(instance, options) do
    query = %{
      createIndexes: @migration_coll,
      indexes: [
        %{key: %{id: 1}, name: "id_ind", unique: true}
      ]
    }

    with {:ok, _} <- Mongo.command(instance, query, options) do
      {:ok, :ensured}
    end
  end

  defp filter_applied(migration_ids, instance, options) do
    applied_list =
      instance
      |> Mongo.find(@migration_coll, %{}, options)
      |> Enum.to_list()
      |> Enum.map(& &1["id"])

    migration_ids
    |> Enum.filter(&(&1 not in applied_list))
  end

  defp mark_applied(migration_id, instance, options) do
    doc = %{"id" => migration_id, "when" => DateTime.utc_now()}
    {:ok, _} = Mongo.insert_one(instance, @migration_coll, doc, options)
    {:ok, :marked}
  end
end
