defmodule GeoTasks.TestDataFactory do
  @moduledoc false

  alias GeoTasks.{Task, User}

  @spec gen_new_task(Map.t()) :: Task.t()
  def gen_new_task(data \\ %{creator_id: nil, assignee_id: nil, status: :created}) do
    %Task{
      id: nil,
      external_id: UUID.uuid1(),
      pickup_loc: data |> Map.get(:pickup_loc, gen_location()),
      delivery_loc: data |> Map.get(:delivery_loc, gen_location()),
      status: data |> Map.get(:status, :created),
      assignee_id: data |> Map.get(:assignee_id, nil),
      creator_id: data |> Map.get(:creator_id, nil),
      created_at: DateTime.utc_now() |> DateTime.truncate(:millisecond)
    }
  end

  @spec gen_location() :: Task.location()
  def gen_location() do
    %{
      lon: :rand.uniform() * 360 - 180,
      lat: :rand.uniform() * 180 - 90
    }
  end

  @spec gen_new_user(User.role()) :: User.t()
  def gen_new_user(role \\ :driver) do
    %User{
      name: UUID.uuid1(),
      role: role,
      created_at: DateTime.utc_now() |> DateTime.truncate(:millisecond)
    }
  end
end
