defmodule GeoTasksWeb.Router do
  use GeoTasksWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(GeoTasksWeb.TokenPlug)
  end

  pipeline :unauthenticated_api do
    plug(:accepts, ["json"])
  end

  scope "/api", GeoTasksWeb do
    scope "/v1" do
      pipe_through :api

      get "/tasks", TaskController, :list
      post "/tasks", TaskController, :create_new
      post "/tasks/:task_id/assign", TaskController, :assign
      post "/tasks/:task_id/complete", TaskController, :complete
    end
  end

  scope "/admin", GeoTasksWeb do
    pipe_through :unauthenticated_api

    get "/users/:role/random/access_token", AdminController, :get_random_access_token
  end
end
