defmodule GeoTasksWeb.TaskControllerTest do
  use GeoTasksWeb.ConnCase, async: true

  alias GeoTasks.{User, UserStorage, TaskManager, AccessToken}
  alias GeoTasks.{TestDataFactory, MapUtils}

  require Logger

  setup do
    cleanup_data()

    %{user: driver, acces_token: token1} = create_user_with_access_token(:driver)
    %{user: manager, acces_token: token2} = create_user_with_access_token(:manager)

    pickup_loc = TestDataFactory.gen_location()
    delivery_loc = TestDataFactory.gen_location()
    {:ok, task} = TaskManager.create_new(pickup_loc, delivery_loc, manager)

    [
      driver: driver,
      driver_token: token1,
      manager: manager,
      manager_token: token2,
      task: task
    ]
  end

  describe "get task" do
    test "token is required", context do
      conn = get(build_conn(), "/api/v1/tasks/#{context[:task].external_id}", token: "")
      body = json_response(conn, 400)
      refute body["success"]
    end

    test "driver can get task by external id", context do
      conn =
        get(build_conn(), "/api/v1/tasks/#{context[:task].external_id}",
          token: context[:driver_token]
        )

      body = json_response(conn, 200)
      assert body["success"]
      assert body["data"]["id"] == context[:task].external_id
    end

    test "manager can get task by external id", context do
      conn =
        get(build_conn(), "/api/v1/tasks/#{context[:task].external_id}",
          token: context[:manager_token]
        )

      body = json_response(conn, 200)
      assert body["success"]
      assert body["data"]["id"] == context[:task].external_id
    end
  end

  describe "list tasks" do
    test "token is required", context do
      conn = get(build_conn(), "/api/v1/tasks", token: "")
      body = json_response(conn, 400)
      refute body["success"]
    end

    test "location is required", context do
      conn = get(build_conn(), "/api/v1/tasks", token: context[:driver_token], location: nil)
      body = json_response(conn, 400)
      refute body["success"]
    end

    test "driver can list tasks", context do
      location = context[:task].pickup_loc

      conn = get(build_conn(), "/api/v1/tasks", token: context[:driver_token], location: location)
      body = json_response(conn, 200)

      assert body["success"]
      assert Enum.count(body["data"]) == 1
    end

    test "manager can list tasks", context do
      location = context[:task].pickup_loc

      conn =
        get(build_conn(), "/api/v1/tasks", token: context[:manager_token], location: location)

      body = json_response(conn, 200)

      assert body["success"]
      assert Enum.count(body["data"]) == 1
    end
  end

  describe "create task" do
    test "token is required", context do
      conn = post(build_conn(), "/api/v1/tasks", token: "")
      body = json_response(conn, 400)
      refute body["success"]
    end

    test "driver can't create tasks", context do
      params = [
        token: context[:driver_token],
        pickup: gen_location(:string),
        delivery: gen_location(:string)
      ]

      conn = post(build_conn(), "/api/v1/tasks", params)
      body = json_response(conn, 403)
      refute body["success"]
    end

    test "manager can create tasks", context do
      pickup_loc = gen_location()
      delivery_loc = gen_location()

      params = [
        token: context[:manager_token],
        pickup: pickup_loc,
        delivery: delivery_loc
      ]

      conn = post(build_conn(), "/api/v1/tasks", params)
      body = json_response(conn, 201)

      assert body["success"]
      assert body["data"]["pickup"] |> MapUtils.atomize_keys() == pickup_loc
      assert body["data"]["delivery"] |> MapUtils.atomize_keys() == delivery_loc
      assert body["data"]["status"] == "created"
    end

    test "pickup location is required", context do
      delivery_loc = gen_location()

      params = [
        token: context[:manager_token],
        pickup: nil,
        delivery: delivery_loc
      ]

      conn = post(build_conn(), "/api/v1/tasks", params)
      body = json_response(conn, 400)

      refute body["success"]
    end

    test "delivery location is required", context do
      pickup_loc = gen_location()

      params = [
        token: context[:manager_token],
        pickup: nil,
        delivery: pickup_loc
      ]

      conn = post(build_conn(), "/api/v1/tasks", params)
      body = json_response(conn, 400)

      refute body["success"]
    end

    test "pickup location can't be the same as delivery location", context do
      pickup_loc = gen_location()
      delivery_loc = pickup_loc

      params = [
        token: context[:manager_token],
        pickup: pickup_loc,
        delivery: delivery_loc
      ]

      conn = post(build_conn(), "/api/v1/tasks", params)
      body = json_response(conn, 400)

      refute body["success"]
    end
  end

  describe "assign task" do
    test "token is required", context do
      conn = post(build_conn(), "/api/v1/tasks/#{context[:task].external_id}/assign", token: "")
      body = json_response(conn, 400)
      refute body["success"]
    end

    test "manager can't get a task assigned", context do
      conn =
        post(build_conn(), "/api/v1/tasks/#{context[:task].external_id}/assign",
          token: context[:manager_token]
        )

      body = json_response(conn, 403)
      refute body["success"]
    end

    test "driver can get a task assigned", context do
      conn =
        post(build_conn(), "/api/v1/tasks/#{context[:task].external_id}/assign",
          token: context[:driver_token]
        )

      body = json_response(conn, 200)
      assert body["success"]
      assert body["data"]["id"] == context[:task].external_id
    end
  end

  describe "complete task" do
    test "token is required", context do
      conn = post(build_conn(), "/api/v1/tasks/#{context[:task].external_id}/complete", token: "")
      body = json_response(conn, 400)
      refute body["success"]
    end

    test "manager can't complete a task", context do
      {:ok, upd_task} = TaskManager.assign(context[:task], context[:driver])

      conn =
        post(build_conn(), "/api/v1/tasks/#{context[:task].external_id}/complete",
          token: context[:manager_token]
        )

      body = json_response(conn, 403)
      refute body["success"]
    end

    test "driver can complete a task", context do
      conn =
        post(build_conn(), "/api/v1/tasks/#{context[:task].external_id}/assign",
          token: context[:driver_token]
        )

      body = json_response(conn, 200)
      assert body["success"]
      assert body["data"]["id"] == context[:task].external_id
    end
  end

  defp create_user_with_access_token(role) do
    {:ok, %User{id: id} = user} =
      role
      |> TestDataFactory.gen_new_user()
      |> UserStorage.create_new()

    {:ok, access_token} = AccessToken.generate_new()
    UserStorage.add_access_token(id, access_token)

    %{user: user, acces_token: access_token}
  end

  defp gen_location(:string) do
    TestDataFactory.gen_location()
    |> location_to_string()
  end

  defp gen_location(), do: TestDataFactory.gen_location()

  defp location_to_string(%{lon: lon, lat: lat}), do: "#{lon},#{lat}"

  defp cleanup_data() do
    GeoTasks.MongoDB.delete_many("tasks", %{})
    GeoTasks.MongoDB.delete_many("users", %{})
  end
end
