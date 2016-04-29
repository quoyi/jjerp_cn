json.array!(@supplies) do |supply|
  json.extract! supply, :id
  json.url supply_url(supply, format: :json)
end
