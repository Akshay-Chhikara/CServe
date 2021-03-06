class Admin < ActiveRecord::Base

  require 'securerandom'

  validates :name, presence: true
  validates :password_confirmation, presence: true, if: :password

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  #FIXME_AB: what should we do with these tickets if admin is destroyed.
  #FIXME_AB: Use inverse_of
  has_many :tickets

  belongs_to :company

  paginates_per 20

  delegate :subdomain, to: :company
  delegate :name, to: :company, prefix: true

  before_validation :set_admin_password_attributes, on: :create

  after_create :send_password_instructions, if: -> { company.admins.count > 1 }
  before_create :skip_confirmation!, if: -> { company.admins.count > 0 }

  def update_with_password(params, *options)
    current_password = params.delete(:current_password)
    result = if valid_password?(current_password)
      update_attributes(params, *options)
    else
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    clean_up_passwords
    result
  end

  private

    def send_password_instructions
      token = set_reset_password_token
      AdminMailer.set_password_instructions(self, token).deliver
    end

    def set_admin_password_attributes
      random_password            = SecureRandom.hex
      self.password              ||= random_password
      self.password_confirmation ||= random_password
    end

end
