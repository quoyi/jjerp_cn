json.array!(@order_categories) do |order_category|
  json.extract! order_category, :id
  json.url order_category_url(order_category, format: :json)
end
