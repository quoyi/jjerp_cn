json.array!(@crafts) do |craft|
  json.extract! craft, :id, :name, :full_name, :note, :status
  json.url craft_url(craft, format: :json)
end
