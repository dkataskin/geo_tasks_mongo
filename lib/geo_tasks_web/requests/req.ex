defmodule GeoTasksWeb.Req do
  defmacro __using__(schema) do
    quote do
      import Ecto.Changeset

      def new, do: cast(%{})
      defp validate(changeset), do: changeset

      def parse_validate(params) do
        changeset = params |> cast() |> validate()

        if changeset.valid? do
          {:valid, changeset.changes}
        else
          {:invalid, changeset}
        end
      end

      defoverridable new: 0, validate: 1

      defp cast(params) do
        data = %{}
        types = Enum.into(unquote(schema), %{})

        empty_map =
          types |> Map.keys() |> Enum.reduce(%{}, fn key, acc -> Map.put(acc, key, nil) end)

        changeset = {data, types} |> Ecto.Changeset.cast(params, Map.keys(types))

        put_in(changeset.changes, Map.merge(empty_map, changeset.changes))
      end
    end
  end
end
