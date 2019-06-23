defmodule GeoTasks.TaskManagerTest do
  use ExUnit.Case

  alias GeoTasks.User
  alias GeoTasks.TaskManager
  alias GeoTasks.TestDataFactory
  alias GeoTasks.UserStorage

  setup do
    cleanup_data()

    on_exit(&cleanup_data/0)
  end

  test "a manager can create a new task" do
    manager = create_user!(:manager)

    pickup_loc = TestDataFactory.gen_location()
    delivery_loc = TestDataFactory.gen_location()

    {:ok, task} = TaskManager.create_new_task(pickup_loc, delivery_loc, manager)
    assert task
    assert task.external_id
    assert task.pickup_loc == pickup_loc
    assert task.delivery_loc == delivery_loc
    assert task.status == :created
    assert task.creator_id == manager.id
  end

  test "a driver can't create a new task" do
    driver = create_user!(:driver)

    pickup_loc = TestDataFactory.gen_location()
    delivery_loc = TestDataFactory.gen_location()

    assert {:error, :not_authorized} ==
             TaskManager.create_new_task(pickup_loc, delivery_loc, driver)
  end

  test "a driver can be assigned a task" do
    driver = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    {:ok, assigned_task} = TaskManager.assign_task(task, driver)
    assert assigned_task
    assert assigned_task.id == task.id
    assert assigned_task.status == :assigned
    assert assigned_task.assignee_id == driver.id
    assert assigned_task.assigned_at
  end

  test "a drive can't be assigned two tasks at the same time" do
    driver = create_user!(:driver)
    manager = create_user!(:manager)
    task1 = create_task!(manager)
    task2 = create_task!(manager)

    {:ok, _} = TaskManager.assign_task(task1, driver)
    assert {:error, :too_many_assigned_tasks} == TaskManager.assign_task(task2, driver)
  end

  test "two drivers can be assigned tasks" do
    driver1 = create_user!(:driver)
    driver2 = create_user!(:driver)
    manager = create_user!(:manager)
    task1 = create_task!(manager)
    task2 = create_task!(manager)

    {:ok, assigned_task1} = TaskManager.assign_task(task1, driver1)
    assert assigned_task1

    {:ok, assigned_task2} = TaskManager.assign_task(task2, driver2)
    assert assigned_task2
  end

  test "a manager can't be assigned a task" do
    manager = create_user!(:manager)
    task = create_task!(manager)

    assert {:error, :not_authorized} == TaskManager.assign_task(task, manager)
  end

  test "a driver can be assigned the same task twice" do
    driver = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    {:ok, assigned_task1} = TaskManager.assign_task(task, driver)
    assert assigned_task1
    assert assigned_task1.id == task.id
    assert assigned_task1.status == :assigned
    assert assigned_task1.assignee_id == driver.id

    {:ok, assigned_task2} = TaskManager.assign_task(assigned_task1, driver)
    assert assigned_task2
    assert assigned_task2.id == task.id
    assert assigned_task2.status == :assigned
    assert assigned_task2.assignee_id == driver.id
  end

  test "a driver can't be assigned to already assigned task" do
    driver1 = create_user!(:driver)
    driver2 = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    {:ok, assigned_task} = TaskManager.assign_task(task, driver1)
    assert {:error, :task_already_assigned} == TaskManager.assign_task(assigned_task, driver2)
  end

  test "a manager can't complete a task" do
    driver = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    {:ok, assigned_task} = TaskManager.assign_task(task, driver)

    assert {:error, :not_authorized} == TaskManager.complete_task(assigned_task, manager)
  end

  test "a driver can complete a task" do
    driver = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    {:ok, assigned_task} = TaskManager.assign_task(task, driver)

    {:ok, completed_task} = TaskManager.complete_task(assigned_task, driver)
    assert completed_task
    assert completed_task.status == :completed
    assert completed_task.completed_at
  end

  test "the same driver can complete a task twice" do
    driver = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    {:ok, assigned_task} = TaskManager.assign_task(task, driver)
    {:ok, completed_task1} = TaskManager.complete_task(assigned_task, driver)
    {:ok, completed_task2} = TaskManager.complete_task(completed_task1, driver)
    assert completed_task1 == completed_task2
  end

  test "only task in status :assigned can be completed" do
    driver = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    assert {:error, :invalid_task_status} == TaskManager.complete_task(task, driver)
  end

  test "only assigned driver can complete a task" do
    driver1 = create_user!(:driver)
    driver2 = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    {:ok, assigned_task} = TaskManager.assign_task(task, driver1)

    assert {:error, :not_authorized} == TaskManager.complete_task(assigned_task, driver2)
  end

  test "completed task can't be reassigned" do
    driver = create_user!(:driver)
    manager = create_user!(:manager)
    task = create_task!(manager)

    {:ok, assigned_task} = TaskManager.assign_task(task, driver)
    {:ok, completed_task} = TaskManager.complete_task(assigned_task, driver)

    assert {:error, :invalid_task_status} == TaskManager.assign_task(completed_task, driver)
  end

  defp create_user!(role) when role in [:driver, :manager] do
    {:ok, %User{} = user} =
      role
      |> TestDataFactory.gen_new_user()
      |> UserStorage.create_new()

    user
  end

  defp create_task!(%User{role: :manager} = manager) do
    pickup_loc = TestDataFactory.gen_location()
    delivery_loc = TestDataFactory.gen_location()

    {:ok, task} = TaskManager.create_new_task(pickup_loc, delivery_loc, manager)
    task
  end

  defp cleanup_data() do
    GeoTasks.MongoDB.delete_many("users", %{})
    GeoTasks.MongoDB.delete_many("tasks", %{})
  end
end
