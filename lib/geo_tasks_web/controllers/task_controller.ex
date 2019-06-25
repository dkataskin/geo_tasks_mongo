defmodule GeoTasksWeb.TaskController do
  use GeoTasksWeb, :controller

  alias GeoTasks.{Task, TaskManager}
  alias GeoTasksWeb.{CreateTaskReq, TaskReq, ListTasksReq, ErrorView}

  require Logger

  def get(conn, params) do
    with {:valid, req} <- TaskReq.parse_validate(params),
         {:ok, task} <- TaskManager.get(req.task_id),
         false <- is_nil(task) do
      render(conn, "task.json", task: task)
    else
      true ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("404.json", errors: %{task_id: "task with specified id not found"})

      error ->
        conn
        |> handle_error(error)
    end
  end

  def create_new(conn, params) do
    with {:valid, req} <- CreateTaskReq.parse_validate(params),
         {:ok, %Task{} = task} <-
           TaskManager.create_new(req.pickup, req.delivery, conn.assigns.user) do
      conn
      |> put_status(:created)
      |> render("task.json", task: task)
    else
      {:error, :not_authorized} ->
        conn
        |> put_status(:forbidden)
        |> put_view(ErrorView)
        |> render("403.json", errors: make_authz_error(:manager, :create))

      error ->
        conn
        |> handle_error(error)
    end
  end

  def assign(conn, params) do
    with {:valid, req} <- TaskReq.parse_validate(params),
         {:ok, task} <- TaskManager.get(req.task_id),
         false <- is_nil(task),
         {:ok, upd_task} <- TaskManager.assign(task, conn.assigns.user) do
      render(conn, "task.json", task: upd_task)
    else
      true ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("404.json", errors: %{task_id: "task with specified id not found"})

      {:error, :not_authorized} ->
        conn
        |> put_status(:forbidden)
        |> put_view(ErrorView)
        |> render("403.json", errors: make_authz_error(:driver, :assign))

      {:error, :too_many_assigned_tasks} ->
        conn
        |> put_status(:bad_request)
        |> put_view(ErrorView)
        |> render("400.json", errors: %{task_id: "another task has been already assigned"})

      {:error, :task_already_assigned} ->
        conn
        |> put_status(:bad_request)
        |> put_view(ErrorView)
        |> render("400.json", errors: %{task_id: "another driver picked up this task already"})

      error ->
        conn
        |> handle_error(error)
    end
  end

  def complete(conn, params) do
    with {:valid, req} <- TaskReq.parse_validate(params),
         {:ok, task} <- TaskManager.get(req.task_id),
         false <- is_nil(task),
         {:ok, upd_task} <- TaskManager.complete(task, conn.assigns.user) do
      render(conn, "task.json", task: upd_task)
    else
      true ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("404.json", errors: %{task_id: "task with specified id not found"})

      {:error, :not_authorized} ->
        conn
        |> put_status(:forbidden)
        |> put_view(ErrorView)
        |> render("403.json", errors: make_authz_error(:driver, :complete))

      {:error, :invalid_task_status} ->
        conn
        |> put_status(:bad_request)
        |> put_view(ErrorView)
        |> render("400.json",
          errors: %{task_id: "task must be assigned before it can be completed"}
        )

      {:error, :wrong_assignee} ->
        conn
        |> put_status(:bad_request)
        |> put_view(ErrorView)
        |> render("400.json",
          errors: %{task_id: "only the user who was assigned this task can complete it"}
        )

      error ->
        conn
        |> handle_error(error)
    end
  end

  def list(conn, params) do
    with {:valid, req} <- ListTasksReq.parse_validate(params),
         {:ok, tasks} <- TaskManager.list(req.location, req.max_distance, req.limit) do
      render(conn, "tasks.json", tasks: tasks)
    else
      error ->
        conn
        |> handle_error(error)
    end
  end

  defp handle_error(conn, error) do
    case error do
      {:invalid, changeset} ->
        conn
        |> put_status(:bad_request)
        |> put_view(ErrorView)
        |> render("400.json", changeset: changeset)

      {:error, :not_authorized} ->
        conn
        |> put_status(:forbidden)
        |> put_view(ErrorView)
        |> render("403.json",
          errors: %{token: "your role doesn't have enough rights to perform this action"}
        )

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> put_view(ErrorView)
        |> render("500.json")
    end
  end

  defp make_authz_error(required_role, action) do
    %{token: "only user with role \"#{required_role}\" can #{action} tasks"}
  end
end
