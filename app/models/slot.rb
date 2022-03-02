class Slot < ApplicationRecord
  belongs_to :event
  validates :start_time, :end_time, presence: true
  attribute :status, default: "pending"
end
