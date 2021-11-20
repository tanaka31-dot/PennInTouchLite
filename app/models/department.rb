class Department < ApplicationRecord
  # TODO: add one-to-many association
  has_many :courses, dependent: :destroy
end
