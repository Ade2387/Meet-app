class Event < ApplicationRecord
  has_many :users, through: :user_events
  has_many :slots, dependent: :destroy
  validates :start, :end, presence: true
  validates :duration, presence: true, numericality: { only_integer: true }
end
