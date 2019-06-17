use Mix.Config

config :geo_tasks, GeoTasksWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Y7nwxYT9qrCsr/Bp0E6tBp+upXw79H3PxM7tqzNVJVtap/qZb1lLokqSbo5knN+e",
  render_errors: [view: GeoTasksWeb.ErrorView, accepts: ~w(json)]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
