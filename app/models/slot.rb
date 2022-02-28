class Slot < ApplicationRecord
  belongs_to :event
  validates :start_at, :end_at, presence: true
  attribute :status, default: "pending"
end
