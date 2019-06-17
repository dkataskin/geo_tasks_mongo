defmodule GeoTasks.MongoMapUtils do
  def map_id!(doc, nil) do
    if Map.has_key?(doc, "_id") do
      doc |> Map.delete("_id")
    else
      doc
    end
  end

  def map_id!(doc, id) do
    doc |> Map.put("_id", id)
  end
end