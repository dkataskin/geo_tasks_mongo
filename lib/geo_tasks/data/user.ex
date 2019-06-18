defmodule GeoTasks.User do
  @enforce_keys [:name, :role, :created_at]

  defstruct id: nil,
            name: nil,
            role: :driver,
            created_at: nil

  @type role :: :driver | :manager

  @type t :: %__MODULE__{
          id: BSON.ObjectId.t(),
          name: String.t(),
          role: role(),
          created_at: DateTime.t()
        }
end
