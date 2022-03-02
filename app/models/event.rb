class Event < ApplicationRecord
  has_many :user_events, dependent: :destroy
  has_many :users, through: :user_events
  has_many :slots, dependent: :destroy
  belongs_to :user
  validates :start_time, :end_time, presence: true
  validates :duration, presence: true, numericality: { only_integer: true }
end
