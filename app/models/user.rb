require 'bcrypt'

class User < ApplicationRecord
    include BCrypt

    has_many :registrations, dependent: :destroy
    has_many :courses, through: :registrations
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :pennkey, presence: true
    validates :pennkey, uniqueness: true
    validates :password_hash, presence: true
    
    def full_name
        "#{first_name} #{last_name}"
    end

    def self.students
        self.where(is_instructor: false)
    end

    def self.instructors
        self.users.where(is_instructor: true)
    end
    
    def password
        @password ||= Password.new(password_hash)
    end
    
    def password=(new_password)
        @password = Password.create(new_password)
        self.password_hash = @password
    end
    
end
