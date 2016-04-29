json.array!(@part_categories) do |part_category|
  json.extract! part_category, :id
  json.url part_category_url(part_category, format: :json)
end
