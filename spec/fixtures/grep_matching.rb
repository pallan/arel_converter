class GrepMatching # < ActiveRecord::Base

  # Associations
  has_many :posts
  has_and_belongs_to_many :articles
  has_one :author
  belongs_to :blog

  def mystery_method
    has_many = 'Test cases'
  end

  # Scopes
  scope :active

  # this comment on scope should not show show up
  def scoping
    scope = 'My Scope'
  end

end
