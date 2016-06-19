json.array!(@banks) do |bank|
  json.extract! bank, :id, :name, :bank_name, :bank_card, :balance
  json.url bank_url(bank, format: :json)
end
