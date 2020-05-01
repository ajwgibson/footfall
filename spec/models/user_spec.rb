require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'User' do
    it 'has a valid default factory' do
      expect(FactoryBot.build(:default_user)).to be_valid
    end
  end

  # VALIDATION
  describe 'A valid user' do
    it 'has a first name' do
      expect(FactoryBot.build(:default_user, first_name: nil)).not_to be_valid
    end
    it 'has a last name' do
      expect(FactoryBot.build(:default_user, last_name: nil)).not_to be_valid
    end
    it 'has a strong password' do
      my_double = double
      expect(PasswordStrengthService).to receive(:new).with('password').and_return(my_double)
      expect(my_double).to receive(:check_password).and_return(['at least one error'])
      u = FactoryBot.build(:default_user, password: 'password', password_confirmation: 'password')
      expect(u).not_to be_valid
    end
  end

  # SCOPES
  describe 'scope:with_name' do
    before(:each) do
      @a = FactoryBot.create(:default_user, first_name: 'Johnny', last_name: 'Smith')
      @b = FactoryBot.create(:default_user, first_name: 'George', last_name: 'Johnson')
      @c = FactoryBot.create(:default_user, first_name: 'Jack',   last_name: 'Jones')
    end
    it 'includes records where either the first or last name contains the value' do
      filtered = User.with_name('John')
      expect(filtered).to     include(@a)
      expect(filtered).to     include(@b)
      expect(filtered).not_to include(@c)
    end
  end

  describe 'scope:with_email' do
    before(:each) do
      @a = FactoryBot.create(:default_user, email: 'joHnny@example.com')
      @b = FactoryBot.create(:default_user, email: 'george@example.com')
    end
    it 'includes records where the email contains the value' do
      filtered = User.with_email('John')
      expect(filtered).to     include(@a)
      expect(filtered).not_to include(@b)
    end
  end

  describe 'scope:ordered_by_name' do
    before(:each) do
      @c = FactoryBot.create(:default_user, first_name: 'c', last_name: 'x')
      @a = FactoryBot.create(:default_user, first_name: 'a', last_name: 'x')
      @b = FactoryBot.create(:default_user, first_name: 'b', last_name: 'x')
      @bb = FactoryBot.create(:default_user, first_name: 'b', last_name: 'y')
    end
    it 'orders records by full name' do
      result = User.ordered_by_name
      expect(result).to eq([@a, @b, @bb, @c])
    end
  end

  # METHODS
  describe '#full_name' do
    it "is 'John Smith' when first_name is 'John' and last_name is 'Smith'" do
      expect(
        FactoryBot.build(
          :default_user,
          first_name: 'John',
          last_name: 'Smith'
        ).full_name
      ).to eq('John Smith')
    end
  end

  describe '#initials' do
    it "is 'JS' when first_name is 'John' and last_name is 'Smith'" do
      expect(
        FactoryBot.build(
          :default_user,
          first_name: 'John',
          last_name: 'Smith'
        ).initials
      ).to eq('JS')
    end
    it 'is always in uppercase by default' do
      expect(
        FactoryBot.build(
          :default_user,
          first_name: 'john',
          last_name: 'smith'
        ).initials
      ).to eq('JS')
    end
  end
end
