use Mix.Config

config :geo_tasks, GeoTasksWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :logger, :console, format: "[$level] $message\n"

config :logger,
  metadata: [:request_id],
  backends: [
    :console,
    {LoggerFileBackend, :file_info},
    {LoggerFileBackend, :file_error}
  ]

config :logger, :file_info,
  metadata: [:request_id],
  path: "logs/info.log",
  format: "\n$date $time $metadata[$level] $levelpad$message",
  level: :info

config :logger, :file_error,
  metadata: [:request_id],
  path: "logs/error.log",
  format: "\n$date $time $metadata[$level] $levelpad$message",
  level: :error
  
config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
