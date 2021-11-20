class Registration < ApplicationRecord
  belongs_to :course
  belongs_to :user
  validates :user, uniqueness: {scope: :course}
end
