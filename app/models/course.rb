class Course < ApplicationRecord
  belongs_to :department
  has_many :registrations, dependent: :destroy
  has_many :users, through: :registrations
  validates :department, presence: true
  validates :code, presence: true
  validates :title, presence: true
  validates :description, presence: true

  def full_code
    "#{department.code}-#{code}"
  end

  validates :code, uniqueness: {scope: :department_id}

  def instructor
    self.users.find_by(is_instructor: true)
  end

  def instructor=(user)
    if user.is_instructor
      self.users << user
    end
  end

  def students
    self.users.where(is_instructor: false)
  end
end
