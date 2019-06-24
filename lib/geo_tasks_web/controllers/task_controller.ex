defmodule GeoTasksWeb.TaskController do
  use GeoTasksWeb, :controller

  alias GeoTasks.{Task, TaskManager}
  alias GeoTasksWeb.{CreateTaskReq, ErrorView}

  require Logger

  def create_new(conn, params) do
    with {:valid, req} <- CreateTaskReq.parse_validate(params),
         {:ok, %Task{} = task} <-
           TaskManager.create_new_task(req.pickup, req.delivery, conn.assigns.user) do
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
    render(conn, %{success: true, data: "test"})
  end

  def complete(conn, params) do
    render(conn, %{success: true, data: "test"})
  end

  defp list(conn, params) do
    render(conn, %{success: true, data: "test"})
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
