defmodule GeoTasks.TaskStorageTest do
  @moduledoc false

  use ExUnit.Case

  alias GeoTasks.Task
  alias GeoTasks.TaskStorage
  alias GeoTasks.UserStorage
  alias GeoTasks.TestDataFactory

  def setup do
    cleanup_data()

    on_exit(&cleanup_data/0)
  end

  test "can create a new task" do
    user = TestDataFactory.gen_new_user()
    {:ok, user} = UserStorage.create_new(user)

    task = TestDataFactory.gen_new_task(%{creator_id: user.id, status: :created})
    result = TaskStorage.create_new(task)
    assert elem(result, 0) == :ok
    task_from_db = elem(result, 1)
    assert task_from_db
    assert task_from_db.id
    assert task_from_db.creator_id == user.id
  end

  test "can read a task by external id" do
    task = TestDataFactory.gen_new_task()
    {:ok, %Task{external_id: external_id} = task1} = TaskStorage.create_new(task)

    {:ok, task2} = TaskStorage.get_by_external_id(external_id)

    assert task2
    assert task1 == task2
  end

  defp cleanup_data() do
    GeoTasks.MongoDB.delete_many("tasks", %{})
  end
end
