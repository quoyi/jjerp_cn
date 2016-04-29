json.array!(@indents) do |indent|
  json.extract! indent, :id
  json.url indent_url(indent, format: :json)
end
