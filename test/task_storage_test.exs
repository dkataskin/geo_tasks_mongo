defmodule GeoTasks.TaskStorageTest do
  @moduledoc false

  use ExUnit.Case

  alias GeoTasks.Task
  alias GeoTasks.{TaskStorage, UserStorage, TestDataFactory}
  alias GeoTasks.Haversine

  setup do
    cleanup_data()
    on_exit(&cleanup_data/0)
  end

  test "can create a new task" do
    user = TestDataFactory.gen_new_user()
    {:ok, user} = UserStorage.create_new(user)

    task = TestDataFactory.gen_new_task(%{creator_id: user.id, status: :created})
    {:ok, task} = TaskStorage.create_new(task)
    assert task
    assert task.id
    assert task.creator_id == user.id
  end

  test "can set assigned status" do
    user = TestDataFactory.gen_new_user()
    {:ok, user} = UserStorage.create_new(user)

    {:ok, task} =
      %{creator_id: user.id, status: :created}
      |> TestDataFactory.gen_new_task()
      |> TaskStorage.create_new()

    assert task

    {:ok, upd_task} = TaskStorage.set_status(task, :assigned, user.id)
    assert upd_task
    assert upd_task.status == :assigned
    assert upd_task.assigned_at
    assert upd_task.ver == task.ver + 1
  end

  test "can set completed status" do
    user = TestDataFactory.gen_new_user()
    {:ok, user} = UserStorage.create_new(user)

    {:ok, task1} =
      %{creator_id: user.id, status: :created}
      |> TestDataFactory.gen_new_task()
      |> TaskStorage.create_new()

    assert task1

    {:ok, task2} = TaskStorage.set_status(task1, :assigned, user.id)
    {:ok, task3} = TaskStorage.set_status(task2, :completed)
    assert task3
    assert task3.status == :completed
    assert task3.completed_at
    assert task3.ver == task2.ver + 1
  end

  test "can read a task by external id" do
    task = TestDataFactory.gen_new_task()
    {:ok, %Task{external_id: external_id} = task1} = TaskStorage.create_new(task)

    {:ok, task2} = TaskStorage.get_by_external_id(external_id)

    assert task2
    assert task1 == task2
  end

  test "can list tasks by distance" do
    task1 = TestDataFactory.gen_new_task(%{pickup_loc: %{lon: 18.060609, lat: 59.331695}})
    {:ok, _} = TaskStorage.create_new(task1)

    task2 = TestDataFactory.gen_new_task(%{pickup_loc: %{lon: 18.070824, lat: 59.331423}})
    {:ok, _} = TaskStorage.create_new(task2)

    task3 = TestDataFactory.gen_new_task(%{pickup_loc: %{lon: 18.054057, lat: 59.335047}})
    {:ok, _} = TaskStorage.create_new(task3)

    task4 = TestDataFactory.gen_new_task(%{pickup_loc: %{lon: 18.023261, lat: 59.328871}})
    {:ok, _} = TaskStorage.create_new(task4)

    driver_loc = %{lon: 18.068876, lat: 59.328025}
    {:ok, tasks} = TaskStorage.list(driver_loc, 10_000, 3)

    sort_check =
      tasks
      |> Enum.map(fn %Task{pickup_loc: pickup_loc} ->
        Haversine.distance(driver_loc, pickup_loc)
      end)
      |> Enum.reduce_while({:ok, 0}, fn distance, {:ok, prev_distance} ->
        if distance >= prev_distance do
          {:cont, {:ok, distance}}
        else
          {:halt, {:error, :not_sorted}}
        end
      end)

    assert Enum.count(tasks) == 3
    assert elem(sort_check, 0) == :ok
    assert elem(sort_check, 1) >= 0
  end

  defp cleanup_data() do
    GeoTasks.MongoDB.delete_many("tasks", %{})
  end
end
