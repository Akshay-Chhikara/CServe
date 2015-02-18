class Company < ActiveRecord::Base

  validates :name, :subdomain, presence: true
  validates :subdomain, uniqueness: { case_sensitive: false },
    exclusion: { in: RESERVED_SUBDOMAINS, message: "%{value} is reserved." },
    format: { with: REGEX[:subdomain] }, if: -> { subdomain.present? }

  has_many :admins, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :categories

  accepts_nested_attributes_for :admins

end
