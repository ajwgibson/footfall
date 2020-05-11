# frozen_string_literal: true

class User < ApplicationRecord

  include Filterable

  enum role: %i[ standard_user administrator ]

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :role,  presence: true
  validate :password_rules

  # Include default devise modules. Others available are:
  # :registerable, :confirmable, :rememberable, :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :validatable,
         :lockable,
         :timeoutable,
         :trackable

  # Only audit deliberate changes - not all the automatic updates made
  # by Devise on each login etc.
  has_paper_trail only: %i[
    first_name last_name email encrypted_password
  ]

  has_one_attached :profile_picture

  # SCOPES
  scope :ordered_by_name, -> { order(first_name: :asc, last_name: :asc) }

  scope :with_name, lambda { |name|
    where('lower(first_name) like lower(?) or lower(last_name) like lower(?)',
          "%#{name}%", "%#{name}%")
  }

  scope :with_email, lambda { |email|
    where('lower(email) like lower(?)', "%#{email}%")
  }

  scope :with_role, ->(value) { where(role: value) }

  # METHODS
  def self.selectable_roles
    User.roles.keys.map { |r| [r.humanize, r] }
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  def human_role
    self.role.humanize
  end

  def avatar
    return unless profile_picture.attached?

    profile_picture.variant(
      combine_options: {
        thumbnail: '150x150^',
        gravity: 'center',
        extent: '150x150'
      }
    )
  end

  private

  def password_rules
    return if password.nil?

    PasswordStrengthService.new(password).check_password.each do |error|
      errors.add :password, error
    end
  end
end
