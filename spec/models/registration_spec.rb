require 'rails_helper'

RSpec.describe Registration, type: :model do
    let!(:student1) {
        User.create(
            first_name: "Student",
            last_name: "Number1",
            pennkey: 'UniqueKey',
            is_instructor: false,
            password_hash: 'asdf'
        )
    }

    let!(:department) {
        Department.create(code: 'CIS', name: 'Computer and Information Science')
    }

    let!(:course1) {
        Course.create(
            department: department,
            code: 196,
            title: 'Test Course',
            description: "test description"
        )
    }

    describe '#user' do
        it 'enforces uniqueness per student-department pair' do
            Registration.create(user: student1, course: course1)
            duplicate_registration = Registration.new(user: student1, course: course1)
            expect(duplicate_registration.valid?).to be false
        end
    end
end