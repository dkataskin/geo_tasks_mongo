use Mix.Config

config :geo_tasks, GeoTasksWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :info

config :geo_tasks,
  mongo: [
    name: :mongo,
    url: "mongodb://localhost:27017/geo_tasks_test?connectTimeoutMS=10000",
    pool_size: 10,
    pool_overflow: 5,
    timeout: 20_000,
    pool_timeout: 5_000
  ]