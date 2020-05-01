# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordStrengthService, type: :service do

  describe 'check_password ensures that the password' do
    def check_password(password)
      PasswordStrengthService.new(password).check_password
    end
    it 'is not too short' do
      expect(check_password('Aa3456789')).to include(
        'must be at least 10 characters long.'
      )
    end
    it 'has at least 1 uppercase character' do
      expect(check_password('aa34567890')).to include(
        'must contain at least one uppercase character.'
      )
    end
    it 'has at least 1 lowercase character' do
      expect(check_password('AA34567890')).to include(
        'must contain at least one lowercase character.'
      )
    end
    it 'has at least 1 digit' do
      expect(check_password('AbCdEfGhIi')).to include(
        'must contain at least one numeric character.'
      )
    end
    it 'does not include the word password' do
      %w[password pa$$word pa$$w0rd p4$$w0rd p4ssword p4ssw0rd].each do |password|
        expect(check_password(password + 'Aa1234')).to include(
          'cannot contain the word password.'
        ), "Did not catch: #{password}"
      end
    end
    it 'does not include the word footfall' do
      %w[footfall f00tfall fo0tfall f0otfall footfa11 footfal1 footfa1l footf4ll].each do |password|
        expect(check_password(password + 'Aa1234')).to include(
          'cannot contain the word footfall.'
        ), "Did not catch: #{password}"
      end
    end
  end
end
