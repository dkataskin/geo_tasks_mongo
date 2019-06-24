defmodule GeoTasksWeb.TokenPlug do
  @moduledoc false

  import Plug.Conn

  alias GeoTasks.UserStorage

  def init(), do: init([])

  def init(opts), do: opts

  def call(conn, _opts) do
    token = conn.params["token"]

    cond do
      is_nil(token) ->
        conn |> render_error(:bad_request, "token is required")

      token |> String.trim() |> String.length() == 0 ->
        conn |> render_error(:bad_request, "token is required")

      String.length(token) > 0 ->
        conn
        |> assign_token(token)
        |> load_user(token)

      true ->
        conn |> render_error(:bad_request, "token is required")
    end
  end

  defp load_user(conn, token) do
    with {:ok, user} <- UserStorage.get_by_access_token(token |> String.trim()),
         false <- is_nil(user) do
      conn
      |> assign(:user, user)
    else
      true ->
        conn |> render_error(:forbidden, "invalid access token")
    end
  end

  defp assign_token(conn, token) do
    conn |> assign(:api_token, token |> String.trim())
  end

  defp render_error(conn, http_error, explanation) do
    error = %{
      success: false,
      errors: %{
        "token" => explanation
      }
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(http_error, error |> Jason.encode!())
    |> halt()
  end
end
