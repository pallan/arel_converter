require 'spec_helper'

describe ArelConverter::Converter do
  #it '' do
    #scope = %Q{scope :active, :conditions => "global_state_cache = 'active'"} # FIXME: this one is dangerous (dvd, 09-07-2010)}
    #parser    = RubyParser.new
    #s = parser.process(scope)
    #puts s.inspect
    #puts Ruby2Ruby.new.process(s)
    #expect(ArelConverter::Converter.translate(scope)).to eq(%Q{scope(:active, where("global_state_cache = 'active'"))})
  #end

   #it 'test' do
    #scope = %Q{scope :active, lambda {|a| {:conditions => ["global_state_cache = ?", a], :order => 'name'} } }
    #parser    = RubyParser.new
    #s = parser.process(scope)
    #puts s.inspect
    #puts Ruby2Ruby.new.process(s)
    #expect(ArelConverter::Converter.translate(scope)).to eq(%Q{scope(:active, where("global_state_cache = 'active'"))})
  #end

end
