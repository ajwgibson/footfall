# frozen_string_literal: true

class PasswordStrengthService

  def initialize(password)
    @password = password
    @errors = []
  end

  def check_password
    unless Rails.env.development?
      check_password_length
      check_password_uppercase
      check_password_lowercase
      check_password_numeric
      check_password_listed
    end

    @errors
  end

  private

  def check_password_length
    if @password.size < MINIMUM_LENGTH
      @errors << "must be at least #{MINIMUM_LENGTH} characters long."
    end
  end

  def check_password_uppercase
    @errors << 'must contain at least one uppercase character.' unless @password.match(/[A-Z]/)
  end

  def check_password_lowercase
    @errors << 'must contain at least one lowercase character.' unless @password.match(/[a-z]/)
  end

  def check_password_numeric
    @errors << 'must contain at least one numeric character.' unless @password.match(/[0-9]/)
  end

  def check_password_listed
    LISTED_WORDS.each do |listed|
      MUNGING_MAPS.each do |munge|
        working_password = @password.dup
        munge.each do |key, value|
          working_password.gsub!(key, value)
          if working_password.downcase.include?(listed)
            @errors << "cannot contain the word #{listed}."
            break
          end
        end
      end
    end
  end

  MINIMUM_LENGTH = 10

  LISTED_WORDS = %w[password footfall].freeze

  # rubocop:disable Metrics/LineLength
  MUNGING_MAPS = [
    { '@' => 'a', '$' => 's', '!' => 'l', '0' => 'o', '1' => 'l', '3' => 'e', '4' => 'a', '5' => 's' },
    { '@' => 'a', '$' => 's', '!' => 'i', '0' => 'o', '1' => 'i', '3' => 'e', '4' => 'a', '5' => 's' },
    { '@' => 'a', '$' => 's', '!' => 'l', '0' => 'o', '1' => 'i', '3' => 'e', '4' => 'a', '5' => 's' },
    { '@' => 'a', '$' => 's', '!' => 'i', '0' => 'o', '1' => 'l', '3' => 'e', '4' => 'a', '5' => 's' }
  ].freeze
  # rubocop:enable Metrics/LineLength
end
