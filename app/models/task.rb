class Task < ApplicationRecord
  enum status: { pending: 0, in_progress: 1, completed: 2 }
  enum priority: { high: 0, medium: 1, low: 2 }

  has_many :assignments
  has_many :users, through: :assignments

  validates :title, presence: true
  validates :description, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :priority, presence: true
end