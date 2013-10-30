require 'spec_helper'

describe ArelConverter::Scope do

  context 'parsing scopes' do
    
    before(:each) do
      @converter = ArelConverter::Scope.new('/tmp')
    end

    context 'with joins' do
      it 'when it is a simple association' do
        scope = %Q{scope :my_scope, :joins => :roles}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, joins(:roles))})
      end

      it 'when it is an array of simple associations' do
        scope = %Q{scope :my_scope, :joins => [:roles, :users]}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, joins([:roles, :users]))})
      end

      it 'when it is a SQL fragment' do
        scope = %Q{scope :my_scope, :joins => "LEFT JOIN `roles` ON roles.scope_id = scopes.id"}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, joins("LEFT JOIN `roles` ON roles.scope_id = scopes.id"))})
      end

      it 'when it is a hash of associations' do
        scope = %Q{scope :my_scope, :joins => {:roles => :users}}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, joins( roles: :users ))})
      end
    end

    context 'with includes' do
      it 'when it is a simple association' do
        scope = %Q{scope :my_scope, :include => :roles}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, includes(:roles))})
      end

      it 'when it is an array of simple associations' do
        scope = %Q{scope :my_scope, :include => [:roles, :users]}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, includes([:roles, :users]))})
      end

      it 'when it is a hash of associations' do
        scope = %Q{scope :my_scope, :include => {:roles => :users}}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, includes( roles: :users ))})
      end
    end

    context 'with conditions' do
      it 'when they are a string' do
        scope = %Q{scope :my_scope, :conditions => "active = 1"}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, where("active = 1"))})
      end

      it 'when they are an array' do
        scope = %Q{scope :my_scope, :conditions => ["active = ?", true]}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, where(["active = ?", true]))})
      end

      it 'where they are a single hash' do
        scope = %Q{scope :my_scope, :conditions => {:active => 1}}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, where( active: 1 ))})
      end

      it 'where they are a hash' do
        scope = %Q{scope :my_scope, :conditions => {:active => 1, :name => 'John'}}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:my_scope, where( active: 1, name: "John" ))})
      end

      it 'where there is a hash including an array' do
        scope = %Q{scope :receivable, :conditions => {:state => ['confirmed', 'partially_received', 'ordered']}}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:receivable, where( state: ["confirmed", "partially_received", "ordered"] ))})
      end

      it 'where there is a where and include' do
        scope = %Q{scope :with_open, :include => :purchase_order, :conditions => ["purchase_orders.state NOT IN ('shopping', 'received', 'cancelled', 'closed')"]}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:with_open, includes(:purchase_order).where(["purchase_orders.state NOT IN ('shopping', 'received', 'cancelled', 'closed')"]))})
      end
    end

    context "with lambdas" do
      it 'should stay on a single line' do
        scope = %Q{scope :for_vendor, lambda{|vendor| {:include => :vendor_purchase_order, :conditions => ["purchase_orders.vendor_id = ?", vendor.id]}}}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:for_vendor, lambda { |vendor| includes(:vendor_purchase_order).where(["purchase_orders.vendor_id = ?", vendor.id]) })})
      end
    end

    context "with multiple options" do
      it 'should concatinate them correctly' do
        scope = %Q{scope :receivable, {:include => [:vendor], :conditions => "state IN ('confirmed','partially_received')"}}
        expect(@converter.process_line(scope)).to eq(%Q{scope(:receivable, includes([:vendor]).where("state IN ('confirmed','partially_received')"))})
      end
    end

  end

end

