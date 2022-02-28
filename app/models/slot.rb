class Slot < ApplicationRecord
  belongs_to :event
  validates :start, :end, presence: true
  attribute :status, default: "pending"
end
