require "rails_helper"

RSpec.describe User, type: :model do
  let!(:instructor1) {
    User.create(
      first_name: "Instructor",
      last_name: "Number1",
      pennkey: "inst1",
      is_instructor: true,
      password_hash: "asdf",
    )
  }

  let!(:instructor2) {
    User.create(
      first_name: "Instructor",
      last_name: "Number2",
      pennkey: "inst2",
      is_instructor: true,
      password_hash: "asdf",
    )
  }

  let!(:student1) {
    User.create(
      first_name: "Student",
      last_name: "Number1",
      pennkey: "UniqueKey",
      is_instructor: false,
      password_hash: "asdf",
    )
  }

  let!(:student2) {
    User.create(
      first_name: "Student",
      last_name: "Number2",
      pennkey: "student2",
      is_instructor: false,
      password_hash: "asdf",
    )
  }

  describe "#first_name" do
    it "validates presence" do
      test_user = User.new(
        first_name: nil,
        last_name: "Number1",
        pennkey: "student1",
        is_instructor: false,
        password_hash: "asdf",
      )
      expect(test_user.valid?).to be false
    end
  end

  describe "#last_name" do
    it "validates presence" do
      test_user = User.new(
        first_name: "Test",
        last_name: nil,
        pennkey: "student1",
        is_instructor: false,
        password_hash: "asdf",
      )
      expect(test_user.valid?).to be false
    end
  end

  describe "#pennkey" do
    it "validates presence" do
      test_user = User.new(
        first_name: "Test",
        last_name: "Student",
        pennkey: nil,
        is_instructor: false,
        password_hash: "asdf",
      )
      expect(test_user.valid?).to be false
    end

    it "validates uniqueness" do
      test_user = User.new(
        first_name: "Test",
        last_name: "Student",
        pennkey: "UniqueKey",
        is_instructor: false,
        password_hash: "asdf",
      )
      expect(test_user.valid?).to be false
    end
  end

  describe "#password_hash" do
    it "validates presence" do
      test_user = User.new(
        first_name: "Test",
        last_name: "User",
        pennkey: "student1",
        is_instructor: false,
        password_hash: nil,
      )
      expect(test_user.valid?).to be false
    end
  end

  describe "#full_name" do
    it "returns the correctly formatted name" do
      expect(student1.full_name).to eq("Student Number1")
    end
  end

  describe ".students" do
    it "returns non-instructor users" do
      expect(User.students).to contain_exactly(student1, student2)
    end
  end

  describe ".instructors" do
    it "returns instructor users" do
      expect(User.instructors).to contain_exactly(instructor1, instructor2)
    end
  end
end
