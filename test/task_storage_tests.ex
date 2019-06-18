defmodule GeoTasks.TaskStorageTests do
  @moduledoc false

  use ExUnit.Case

  alias GeoTasks.Task
  alias GeoTasks.TaskStorage
  alias GeoTasks.TaskFactory

  def setup do
    cleanup_data()

    on_exit(&cleanup_data/0)
  end

  test "can create a new task" do
    task = TaskFactory.gen_new_task()
    result = TaskStorage.create_new(task)
    assert elem(result, 0) == :ok
  end

  test "can read a task by external id" do
    task = TaskFactory.gen_new_task()
    {:ok, %Task{external_id: external_id} = task1} = TaskStorage.create_new(task)

    {:ok, task2} = TaskStorage.get_by_external_id(external_id)

    assert task2
    assert task1 == task2
  end

  defp cleanup_data() do
    GeoTasks.MongoDB.delete_many("tasks", %{})
  end
end
