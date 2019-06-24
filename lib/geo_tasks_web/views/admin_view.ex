defmodule GeoTasksWeb.AdminView do
  use GeoTasksWeb, :view

  def render("access_token.json", %{access_token: access_token}) do
    %{
      success: true,
      data: access_token
    }
  end
end
