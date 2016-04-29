json.array!(@user_categories) do |user_category|
  json.extract! user_category, :id
  json.url user_category_url(user_category, format: :json)
end
