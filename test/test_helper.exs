alias GeoTasks.Storage.Migrator
alias GeoTasks.Config

mongo_opts = Config.get_mongo_opts!()

:ok = Migrator.up(:mongo, mongo_opts)

ExUnit.start()
