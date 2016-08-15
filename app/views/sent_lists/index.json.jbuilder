json.array!(@sent_lists) do |sent_list|
  json.extract! sent_list, :id, :name, :total, :created_by, :deleted
  json.url sent_list_url(sent_list, format: :json)
end
