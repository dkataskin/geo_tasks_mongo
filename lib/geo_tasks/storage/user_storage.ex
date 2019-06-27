defmodule GeoTasks.UserStorage do
  @moduledoc false

  import GeoTasks.MongoMapUtils, only: [map_id!: 2]

  alias GeoTasks.User
  alias GeoTasks.MongoDB

  require Logger

  @coll "users"

  @type single_user_result :: {:ok, User.t()} | {:error, any()}

  @spec create_new(User.t()) :: single_user_result
  def create_new(%User{id: nil} = user) do
    with {:ok, id} <- MongoDB.insert_one(@coll, map_to_db(user)) do
      {:ok, %User{user | id: id}}
    else
      error ->
        Logger.error("An error occurred while inserting a new user: #{inspect(error)}")
        error
    end
  end

  @spec get_by_id(BSON.ObjectId.t()) :: single_user_result
  def get_by_id(%BSON.ObjectId{} = id) do
    with {:ok, user} <- MongoDB.find_one(@coll, %{"_id" => id}, map_fn: &map_from_db/1) do
      {:ok, user}
    else
      error ->
        Logger.error("An error occurred while getting a user: #{inspect(error)}")
        error
    end
  end

  @spec add_access_token(BSON.ObjectId.t(), User.access_token()) ::
          {:ok, :added} | {:error, any()}
  def add_access_token(%BSON.ObjectId{} = user_id, access_token) when is_binary(access_token) do
    filter = %{"_id" => user_id}

    update = %{
      "$addToSet" => %{
        "access_tokens" => access_token
      }
    }

    with {:ok, _} <-
           MongoDB.find_one_and_update(@coll, filter, update, return_document_after: true) do
      {:ok, :added}
    end
  end

  @spec get_by_access_token(User.access_token()) :: single_user_result
  def get_by_access_token(access_token) when is_binary(access_token) do
    with {:ok, user} <-
           MongoDB.find_one(@coll, %{"access_tokens" => access_token}, map_fn: &map_from_db/1) do
      {:ok, user}
    else
      error ->
        Logger.error("An error occurred while getting a user by access token: #{inspect(error)}")
        error
    end
  end

  @spec get_random(User.role()) :: single_user_result
  def get_random(role) do
    with {:ok, count} <- MongoDB.count(@coll, %{"role" => role}),
         true <- count > 0,
         skip = :rand.uniform(count - 1),
         [%User{} = user] <-
           MongoDB.find(@coll, %{"role" => role}, limit: 1, skip: skip, map_fn: &map_from_db/1) do
      {:ok, user}
    else
      false ->
        {:ok, nil}

      error ->
        error
    end
  end

  @spec get_access_tokens(BSON.ObjectId.t()) :: {:ok, [String.t()]} | {:error, any()}
  def get_access_tokens(%BSON.ObjectId{} = user_id) do
    with {:ok, user_db} <- MongoDB.find_one(@coll, %{"_id" => user_id}),
         false <- is_nil(user_db) do
      {:ok, user_db |> Map.get("access_tokens", [])}
    else
      true ->
        {:ok, []}

      error ->
        error
    end
  end

  @spec map_to_db(User.t()) :: BSON.document()
  defp map_to_db(%User{id: id, role: role, name: name, created_at: created_at}) do
    %{
      "name" => name,
      "role" => role,
      "created_at" => created_at || DateTime.utc_now() |> DateTime.truncate(:millisecond)
    }
    |> map_id!(id)
  end

  @spec map_from_db(nil | BSON.document()) :: nil | User.t()
  defp map_from_db(nil), do: nil

  defp map_from_db(%{"_id" => id, "name" => name, "role" => role, "created_at" => created_at}) do
    %User{
      id: id,
      name: name,
      role: role |> String.to_atom(),
      created_at: created_at
    }
  end
end
