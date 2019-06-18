defmodule GeoTasks.TaskManager do
  @moduledoc false

  alias GeoTasks.{User, Task}
  alias GeoTasks.TaskStorage

  @spec create_new_task(Task.location(), User.t()) ::
          {:ok, Task.t()} | {:error, :not_authorized} | {:error, :any}
  def create_new_task(%{lon: _lon, lat: _lat} = location, %User{} = creator) do
    with {:authorized, true} <- {:authorized, is_allowed_create_tasks?(creator)},
         task = new_task(location, creator),
         {:ok, %Task{} = task} <- TaskStorage.create_new(task) do
      {:ok, task}
    else
      {:authorized, false} ->
        {:error, :not_authorized}

      error ->
        error
    end
  end

  @spec assign_task(Task.t(), User.t()) :: {:ok, Task.t()} | {:error, :task_already_assigned}
  def assign_task(%Task{status: :assigned} = task, %User{} = assignee) do
    with {:authorized, true} <- {:authorized, is_allowed_assign_tasks?(assignee)},
         {:same_assignee, true} <- {:same_assignee, task.assignee_id == assignee.id} do
      {:ok, task}
    else
      {:authorized, false} ->
        {:error, :not_authorized}

      {:same_assignee, false} ->
        {:error, :task_already_assigned}
    end
  end

  @spec assign_task(Task.t(), User.t()) ::
          {:ok, Task.t()}
          | {:error, :not_authorized}
          | {:error, :task_already_assigned}
          | {:error, any()}
  def assign_task(%Task{status: :created} = task, %User{} = assignee) do
    with {:authorized, true} <- {:authorized, is_allowed_assign_tasks?(assignee)},
         {:ok, upd_task} <- TaskStorage.set_status(task, :assigned, assignee.id),
         {:task_updated, true} <- {:task_updated, not is_nil(upd_task)} do
      {:ok, upd_task}
    else
      {:authorized, false} ->
        {:error, :not_authorized}

      {:task_updated, false} ->
        {:error, :task_already_assigned}

      error ->
        error
    end
  end

  @spec complete_task(Task.t(), User.t()) ::
          {:ok, Task.t()} | {:error, :not_authorized} | {:error, any()}
  def complete_task(%Task{} = task, %User{} = assignee) do
    with {:status, :assigned} <- {:status, task.status},
         {:authorized, true} <- {:authorized, is_allowed_complete_tasks?(assignee)},
         {:authorized, true} <- {:authorized, task.assignee_id === assignee.id},
         {:ok, upd_task} <- TaskStorage.set_status(task, :completed),
         {:task_updated, true, _task} <- {:task_updated, not is_nil(upd_task), upd_task} do
      {:ok, upd_task}
    else
      {:status, _status} ->
        {:error, :invalid_task_status}

      {:authorized, false} ->
        {:error, :not_authorized}

      {:task_updated, false, task} ->
        {:ok, task}

      error ->
        error
    end
  end

  @spec new_task(Task.location(), User.t()) :: Task.t()
  defp new_task(%{lon: _lon, lat: _lat} = location, %User{id: id}) do
    %Task{
      external_id: UUID.uuid1(),
      location: location,
      status: :created,
      creator_id: id,
      created_at: DateTime.utc_now() |> DateTime.truncate(:millisecond)
    }
  end

  @spec is_allowed_create_tasks?(User.t()) :: boolean()
  defp is_allowed_create_tasks?(%User{role: :manager}), do: true
  defp is_allowed_create_tasks?(%User{role: _role}), do: false

  @spec is_allowed_assign_tasks?(User.t()) :: boolean()
  defp is_allowed_assign_tasks?(%User{role: :driver}), do: true
  defp is_allowed_assign_tasks?(%User{role: _role}), do: false

  @spec is_allowed_complete_tasks?(User.t()) :: boolean()
  defp is_allowed_complete_tasks?(%User{role: :driver}), do: true
  defp is_allowed_complete_tasks?(%User{role: _role}), do: false
end
