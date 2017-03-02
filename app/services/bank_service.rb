class BankService < BaseService
  def self.update_bank(bank_id, params)
    bank = Bank.find(bank_id)
    bank.update(params)
  end
end
