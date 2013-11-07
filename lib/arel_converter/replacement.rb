module ArelConverter
  class Replacement
    include Comparable

    attr_accessor :old_content, :new_content, :error

    def initialize(old_content=nil, new_content=nil)
      @old_content = old_content
      @new_content = new_content
    end

    def valid?
      @error.nil?
    end

    def <=>(other)
      [self.old_content, self.new_content] <=> [other.old_content, other.new_content]
    end

  end
end
