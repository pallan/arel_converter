module ArelConverter
  class Base
    def initialize(path = './')
      @path       = path
      @parser     = RubyParser.new
      @translator = Ruby2Ruby.new
    end
  end
end
