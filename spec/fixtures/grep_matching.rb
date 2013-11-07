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
  scope :active, :conditions => ['status NOT IN (?)', ['closed','cancelled']]

  # this comment on scope should not show show up
  def scoping
    scope = 'My Scope'
  end

  # Finders
  def finder_calls
    Model.find(:all)

    Model.find(:first)

    Model.find(:all, :conditions => {:active => true})

    Model.all(:conditions => {:active => false})

    Model.first(:conditions => {:active => false})

    # should not be found
    Model.all
    Model.first
  end

end
