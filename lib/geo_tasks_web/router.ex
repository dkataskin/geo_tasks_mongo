defmodule GeoTasksWeb.Router do
  use GeoTasksWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GeoTasksWeb do
    pipe_through :api
  end
end
