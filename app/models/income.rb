class Income < ActiveRecord::Base
  belongs_to :indent
  belongs_to :bank
end
