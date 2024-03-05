class User < ApplicationRecord
  has_many :assignments
  has_many :tasks, through: :assignments
end