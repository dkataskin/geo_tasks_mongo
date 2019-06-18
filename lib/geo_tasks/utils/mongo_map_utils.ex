defmodule GeoTasks.MongoMapUtils do
  @moduledoc false

  @spec map_id!(BSON.document(), nil) :: BSON.document()
  def map_id!(doc, nil) do
    if Map.has_key?(doc, "_id") do
      doc |> Map.delete("_id")
    else
      doc
    end
  end

  @spec map_id!(BSON.document(), BSON.ObjectId.t()) :: BSON.document()
  def map_id!(doc, id) do
    doc |> Map.put("_id", id)
  end
end
