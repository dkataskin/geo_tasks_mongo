defmodule GeoTasks.MongoDB do
  @moduledoc false

  @mongo_opts [pool: DBConnection.Poolboy, pool_timeout: 5_000, timeout: 20_000]
  @topology :mongo

  def insert_one(collection, doc) do
    with {:ok, %Mongo.InsertOneResult{inserted_id: id}} <-
           Mongo.insert_one(@topology, collection, doc, @mongo_opts) do
      {:ok, id}
    end
  end

  def insert_many(collection, docs, opts) do
    Mongo.insert_many(@topology, collection, docs, Keyword.merge(opts, @mongo_opts))
  end

  def find_one(collection, filter, opts) do
    map_fn = opts[:map_fn] || fn db_item -> db_item end

    with %Mongo.Error{} = mongo_err <- Mongo.find_one(@topology, collection, filter, @mongo_opts) do
      {:error, mongo_err}
    else
      {:error, error} ->
        {:error, error}

      db_item ->
        {:ok, map_fn.(db_item)}
    end
  end

  def find_one_and_update(collection, filter, update, opts \\ [return_document: :after]) do
    map_fn = opts[:map_fn] || fn db_item -> db_item end

    with {:ok, db_item} <-
           Mongo.find_one_and_update(
             @topology,
             collection,
             filter,
             update,
             Keyword.merge(opts, @mongo_opts)
           ) do
      {:ok, map_fn.(db_item)}
    end
  end

  def find_one_and_replace(collection, filter, doc, opts) do
    Mongo.find_one_and_replace(
      @topology,
      collection,
      filter,
      doc,
      Keyword.merge(opts, @mongo_opts)
    )
  end

  def update_one(collection, filter, update, opts) do
    Mongo.update_one(@topology, collection, filter, update, Keyword.merge(opts, @mongo_opts))
  end

  def update_many(collection, filter, update, opts) do
    Mongo.update_many(@topology, collection, filter, update, Keyword.merge(opts, @mongo_opts))
  end

  def delete_one(collection, filter, opts) do
    Mongo.delete_one(@topology, collection, filter, Keyword.merge(opts, @mongo_opts))
  end

  def delete_many(collection, filter) do
    Mongo.delete_many(@topology, collection, filter, @mongo_opts)
  end

  def find(collection, filter, opts) do
    map_fn = opts[:map_fn] || fn db_item -> db_item end

    with %Mongo.Cursor{} = cursor <-
           Mongo.find(@topology, collection, filter, Keyword.merge(opts, @mongo_opts)) do
      cursor |> Enum.map(map_fn)
    end
  end

  def distinct(collection, field, filter, opts) do
    Mongo.distinct(@topology, collection, field, filter, Keyword.merge(opts, @mongo_opts))
  end

  def aggregate(collection, query, opts \\ [return_document: :after]) do
    Mongo.aggregate(@topology, collection, query, Keyword.merge(opts, @mongo_opts))
  end

  def count(collection, filter, opts) do
    Mongo.count(@topology, collection, filter, Keyword.merge(opts, @mongo_opts))
  end

  def explain_error(%Mongo.Error{code: 11_000}), do: :duplicate_key_error
  def explain_error(error), do: error
end
