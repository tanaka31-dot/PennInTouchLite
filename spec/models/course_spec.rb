require 'rails_helper'

RSpec.describe Course, type: :model do
    let!(:department) {
        Department.create(code: 'CIS', name: 'Computer and Information Science')
    }

    let!(:t_course) {
        Course.create(
            department: department,
            code: 196,
            title: 'Test Course',
            description: "test description"
        )
    }

    let!(:instructor1) {
        User.create(
            first_name: "Instructor",
            last_name: "Number1",
            pennkey: 'inst1',
            is_instructor: true,
            password_hash: 'asdf'
        )
    }

    let!(:instructor2) {
        User.create(
            first_name: "Instructor",
            last_name: "Number2",
            pennkey: 'inst2',
            is_instructor: true,
            password_hash: 'asdf'
        )
    }

    let!(:student1) {
        User.create(
            first_name: "Student",
            last_name: "Number1",
            pennkey: 'student1',
            is_instructor: false,
            password_hash: 'asdf'
        )
    }

    let!(:student2) {
        User.create(
            first_name: "Student",
            last_name: "Number2",
            pennkey: 'student2',
            is_instructor: false,
            password_hash: 'asdf'
        )
    }

    describe '#department' do
        it 'validates presence' do
            test_course = Course.new(
                department: nil,
                code: 100,
                title: "Test Course",
                description: "Test Description"
            )
            expect(test_course.valid?).to be false
        end
    end

    describe '#code' do
        it 'validates presence' do
            test_course = Course.new(
                department: department,
                code: nil,
                title: "Test Course",
                description: "Test Description"
            )
            expect(test_course.valid?).to be false
        end
    end

    describe '#title' do
        it 'validates presence' do
            test_course = Course.new(
                department: department,
                code: 100,
                title: nil,
                description: "Test Description"
            )
            expect(test_course.valid?).to be false
        end
    end

    describe '#description' do
        it 'validates presence' do
            test_course = Course.new(
                department: department,
                code: 100,
                title: 'Test Course',
                description: nil
            )
            expect(test_course.valid?).to be false
        end
    end

    describe '#full_code' do
        it 'returns the properly formatted code' do
            test_course = Course.new(
                department: department,
                code: 100,
                title: 'Test Course',
                description: "test description"
            )
            expect(test_course.full_code).to eq ('CIS-100')
        end

        it 'is unique among courses' do # xcxc TODO
            test_course = Course.new(
                department: department,
                code: 196,
                title: 'Ruby on Rails 2',
                description: "The long awaited sequel"
            )

            expect(test_course.valid?).to be false
        end
    end

    describe '#instructor' do
        it 'gets the first instructor added' do
            t_course.users << student1
            t_course.users << student2
            t_course.users << instructor2
            expect(t_course.instructor).to eq(instructor2)
        end
    end

    describe '#instructor=' do
        it 'adds instructor to users list' do
            t_course.users << student1
            expect(t_course.users.length).to equal(1)
            t_course.instructor = instructor1
            expect(t_course.users.length).to equal(2)
        end

        it 'does not add ordinary student to users list' do
            t_course.users << student1
            expect(t_course.users.length).to equal(1)
            t_course.instructor = student2
            expect(t_course.users.length).to equal(1)
        end
    end

    describe '#students' do
        it 'gives all users who are not instructors' do
            t_course.users << student1
            t_course.users << student2
            t_course.users << instructor2
            t_course.users << instructor1
            expect(t_course.students).to contain_exactly(student1, student2)
        end
    end
end

