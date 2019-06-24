defmodule GeoTasksWeb.ErrorView do
  use GeoTasksWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  def render("403.json", %{errors: errors}) do
    %{
      success: false,
      errors: errors
    }
  end

  def render("400.json", %{changeset: changeset}) do
    %{
      success: false,
      errors: changeset |> Ecto.Changeset.traverse_errors(&translate_error/1)
    }
  end

  def render("400.json", %{errors: errors}) do
    %{
      success: false,
      errors: errors
    }
  end

  def render("500.json", _assigns) do
    %{
      success: false,
      errors: %{detail: "Internal Server Error"}
    }
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
