class Associations # < ActiveRecord::Base

  has_many :posts

  has_and_belongs_to_many :articles

  has_one :author

  belongs_to :blog

  def mystery_method
    has_many = 'Test cases'
  end

end
