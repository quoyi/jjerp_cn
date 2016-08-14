class Sent < ActiveRecord::Base
  belongs_to :sent_list
  belongs_to :owner, polymorphic: true
end
