defmodule GeoTasks.MongoDB do
  @moduledoc false

  @type result(t) :: :ok | {:ok, t} | {:error, Mongo.Error.t()} | {:error, any()}
  @type id_result :: Mongo.result(BSON.ObjectId.t())
  @type err_result :: {:error, Mongo.Error.t()} | {:error, any()}

  @mongo_opts [pool: DBConnection.Poolboy, pool_timeout: 5_000, timeout: 20_000]
  @topology :mongo

  @spec insert_one(Mongo.collection(), BSON.document()) :: id_result | err_result
  def insert_one(collection, doc) do
    with {:ok, %Mongo.InsertOneResult{inserted_id: id}} <-
           Mongo.insert_one(@topology, collection, doc, @mongo_opts) do
      {:ok, id}
    end
  end

  @spec insert_many(Mongo.collection(), [BSON.document()], Keyword.t()) ::
          result(Mongo.InsertManyResult.t())
  def insert_many(collection, docs, opts) do
    Mongo.insert_many(@topology, collection, docs, Keyword.merge(opts, @mongo_opts))
  end

  @spec find_one(Mongo.collection(), BSON.document(), Keyword.t()) :: result(Map.t())
  def find_one(collection, filter, opts \\ []) do
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

  @spec find_one_and_update(Mongo.collection(), Map.t(), Map.t(), Keyword.t()) ::
          result(BSON.document())
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

  @spec find_one_and_replace(Mongo.collection(), Map.t(), BSON.document(), Keyword.t()) ::
          result(BSON.document())
  def find_one_and_replace(collection, filter, doc, opts) do
    Mongo.find_one_and_replace(
      @topology,
      collection,
      filter,
      doc,
      Keyword.merge(opts, @mongo_opts)
    )
  end

  @spec delete_many(Mongo.collection(), BSON.document()) ::
          {:ok, Mongo.DeleteResult.t()} | {:error, any()}
  def delete_many(collection, filter) do
    Mongo.delete_many(@topology, collection, filter, @mongo_opts)
  end

  @spec find(Mongo.collection(), BSON.document(), Keyword.t()) ::
          Mongo.Cursor.t() | {:error, any()}
  def find(collection, filter, opts) do
    map_fn = opts[:map_fn] || fn db_item -> db_item end

    with %Mongo.Cursor{} = cursor <-
           Mongo.find(@topology, collection, filter, Keyword.merge(opts, @mongo_opts)) do
      cursor |> Enum.map(map_fn)
    end
  end

  @spec aggregate(Mongo.collection(), BSON.document(), Keyword.t()) ::
          Mongo.Cursor.t() | {:error, any()}
  def aggregate(collection, query, opts \\ [return_document: :after]) do
    Mongo.aggregate(@topology, collection, query, Keyword.merge(opts, @mongo_opts))
  end

  @spec count(Mongo.collection(), BSON.document(), Keyword.t()) ::
          {:ok, non_neg_integer()} | {:error, any()}
  def count(collection, filter, opts \\ []) do
    Mongo.count(@topology, collection, filter, Keyword.merge(opts, @mongo_opts))
  end

  @spec explain_error(Mongo.Error.t()) :: atom() | Mongo.Error.t()
  def explain_error(%Mongo.Error{code: 11_000}), do: :duplicate_key_error
  def explain_error(error), do: error
end
