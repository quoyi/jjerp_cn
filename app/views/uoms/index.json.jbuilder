json.array!(@uoms) do |uom|
  json.extract! uom, :id, :name, :val, :note, :deleted
  json.url uom_url(uom, format: :json)
end
