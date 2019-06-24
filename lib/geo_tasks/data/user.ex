defmodule GeoTasks.User do
  @moduledoc false

  @enforce_keys [:name, :role]

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
