require 'spec_helper'

describe ArelConverter::Translator::Options do

  context 'parsing ActiveRecord options' do

    context 'as a S-Expression' do
      it 'should work with the same results as a string' do
        code_fragment = %Q{{:joins => :roles}}
        sexp = RubyParser.new.process(code_fragment)
        expect(ArelConverter::Translator::Options.translate(sexp)).to eq(ArelConverter::Translator::Options.translate(code_fragment))
      end
    end

    context 'as a string' do

      context 'with joins' do
        it 'when it is a simple association' do
          scope = %Q{{:joins => :roles}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{joins(:roles)})
        end

        it 'when it is an array of simple associations' do
          scope = %Q{{:joins => [:roles, :users]}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{joins([:roles, :users])})
        end

        it 'when it is a SQL fragment' do
          scope = %Q{{:joins => "LEFT JOIN `roles` ON roles.scope_id = scopes.id"}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{joins("LEFT JOIN `roles` ON roles.scope_id = scopes.id")})
        end

        it 'when it is a hash of associations' do
          scope = %Q{{:joins => {:roles => :users}}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{joins( roles: :users )})
        end
      end

      context 'with includes' do
        it 'when it is a simple association' do
          scope = %Q{{:include => :roles}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{includes(:roles)})
        end

        it 'when it is an array of simple associations' do
          scope = %Q{{:include => [:roles, :users]}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{includes([:roles, :users])})
        end

        it 'when it is a hash of associations' do
          scope = %Q{{:include => {:roles => :users}}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{includes( roles: :users )})
        end
      end

      context 'with conditions' do
        it 'when they are a string' do
          scope = %Q{{:conditions => "active = 1"}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{where("active = 1")})
        end

        it 'when they are an array' do
          scope = %Q{{:conditions => ["active = ?", true]}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{where(["active = ?", true])})
        end

        it 'where they are a single hash' do
          scope = %Q{{:conditions => {:active => 1}}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{where( active: 1 )})
        end

        it 'where they are a hash' do
          scope = %Q{{:conditions => {:active => 1, :name => 'John'}}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{where( active: 1, name: "John" )})
        end

        it 'where there is a hash including an array' do
          scope = %Q{{:conditions => {:state => ['confirmed', 'partially_received', 'ordered']}}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{where( state: ["confirmed", "partially_received", "ordered"] )})
        end

        it 'where there is a where and include' do
          scope = %Q{{:include => :purchase_order, :conditions => ["purchase_orders.state NOT IN ('shopping', 'received', 'cancelled', 'closed')"]}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{includes(:purchase_order).where(["purchase_orders.state NOT IN ('shopping', 'received', 'cancelled', 'closed')"])})
        end
      end

      context "with lambdas" do
        it 'should stay on a single line' do
          scope = %Q{lambda{|vendor| {:include => :vendor_purchase_order, :conditions => ["purchase_orders.vendor_id = ?", vendor.id]}}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{lambda { |vendor| includes(:vendor_purchase_order).where(["purchase_orders.vendor_id = ?", vendor.id]) }})
        end
      end

      context "with multiple options" do
        it 'should concatinate them correctly' do
          scope = %Q{{:include => [:vendor], :conditions => "state IN ('confirmed','partially_received')"}}
          expect(ArelConverter::Translator::Options.translate(scope)).to eq(%Q{includes([:vendor]).where("state IN ('confirmed','partially_received')")})
        end
      end
    end
  end
end

