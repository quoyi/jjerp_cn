json.array!(@sents) do |sent|
  json.extract! sent, :id, :indent_id, :name, :sent_at, :area, :receiver, :contact, :cupboard, :robe, :door, :part, :collection, :collection, :logistics, :logistics_code
  json.url sent_url(sent, format: :json)
end
