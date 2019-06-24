defmodule GeoTasksWeb.AdminController do
  use GeoTasksWeb, :controller

  alias GeoTasksWeb.ErrorView
  alias GeoTasks.{User, UserStorage, StringUtils}

  def get_random_access_token(conn, %{"role" => role_str}) do
    with role <- parse_role(role_str |> StringUtils.downcase_safe()),
         false <- is_nil(role),
         {:ok, %User{id: id}} <- UserStorage.get_random(role),
         {:ok, access_tokens} <- UserStorage.get_access_tokens(id) do
      render(conn, "access_token.json", access_token: access_tokens |> Enum.random())
    else
      true ->
        conn
        |> put_status(400)
        |> put_view(ErrorView)
        |> render("400.json", errors: [%{detail: "Invalid role"}])

      {:error, _reason} ->
        conn
        |> put_status(500)
        |> put_view(ErrorView)
        |> render("500.json")
    end
  end

  defp parse_role(nil), do: nil
  defp parse_role("manager"), do: :manager
  defp parse_role("driver"), do: :driver
end
