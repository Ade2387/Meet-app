class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :photo
  validates :email, presence: true, uniqueness: true
  has_many :user_events, dependent: :destroy
  has_many :events, through: :user_events
  has_many :events
end
