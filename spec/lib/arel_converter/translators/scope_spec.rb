require 'spec_helper'

describe ArelConverter::Translator::Scope do

  context 'parsing scopes' do

    context 'with joins' do
      it 'when it is a simple association' do
        scope = %Q{scope :my_scope, :joins => :roles}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { joins(:roles) }})
      end

      it 'when it is an array of simple associations' do
        scope = %Q{scope :my_scope, :joins => [:roles, :users]}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { joins(:roles, :users) }})
      end

      it 'when it is a SQL fragment' do
        scope = %Q{scope :my_scope, :joins => "LEFT JOIN `roles` ON roles.scope_id = scopes.id"}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { joins("LEFT JOIN `roles` ON roles.scope_id = scopes.id") }})
      end

      it 'when it is a hash of associations' do
        scope = %Q{scope :my_scope, :joins => {:roles => :users}}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { joins( roles: :users ) }})
      end
    end

    context 'with includes' do
      it 'when it is a simple association' do
        scope = %Q{scope :my_scope, :include => :roles}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { includes(:roles) }})
      end

      it 'when it is an array of simple associations' do
        scope = %Q{scope :my_scope, :include => [:roles, :users]}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { includes(:roles, :users) }})
      end

      it 'when it is a hash of associations' do
        scope = %Q{scope :my_scope, :include => {:roles => :users}}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { includes( roles: :users ) }})
      end

      it 'when there is a nested hash of associations' do
        scope = %Q{scope :my_scope, :include => [:author => {:roles => :users}]}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { includes( author: { roles: :users } ) }})
      end

      it 'when there is an array of associations with a nested hash of' do
        scope = %Q{scope :my_scope, :include => [ {:strengths => :unit}, :origin_country, :unit]}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { includes({ strengths: :unit }, :origin_country, :unit) }})
      end
    end

    context 'with conditions' do
      it 'when they are a string' do
        scope = %Q{scope :my_scope, :conditions => "active = 1"}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { where("active = 1") }})
      end

      it 'when they are an array' do
        scope = %Q{scope :my_scope, :conditions => ["active = ?", true]}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { where("active = ?", true) }})
      end

      it 'where they are a single hash' do
        scope = %Q{scope :my_scope, :conditions => {:active => 1}}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { where( active: 1 ) }})
      end

      it 'where they are a hash' do
        scope = %Q{scope :my_scope, :conditions => {:active => 1, :name => 'John'}}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { where( active: 1, name: "John" ) }})
      end

      it 'where there is a hash including an array' do
        scope = %Q{scope :my_scope, :conditions => {:state => ['confirmed', 'partially_received', 'ordered']}}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { where( state: ["confirmed", "partially_received", "ordered"] ) }})
      end

      it 'where there is a where and include' do
        scope = %Q{scope :my_scope, :include => :purchase_order, :conditions => ["purchase_orders.state NOT IN ('shopping', 'received', 'cancelled', 'closed')"]}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { includes(:purchase_order).where("purchase_orders.state NOT IN ('shopping', 'received', 'cancelled', 'closed')") }})
      end

      it 'where there is a hash with string keys' do
        scope = %Q{scope :my_scope, :conditions => {'products.generic' => true}}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { where( "products.generic" => true ) }})
      end
    end

    context "with lambdas" do
      it 'should not change an existing Arel call (very much)' do
        scope = %Q{scope :for_state, lambda {|state| where(:state => state.to_s.upcase) }}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :for_state, lambda { |state| where(state: state.to_s.upcase) }})
      end
      it 'should not change existing chained Arel calls (very much)' do
        scope = %Q{scope :for_state, lambda {|state| where(:state => state.to_s.upcase).order(:name) }}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :for_state, lambda { |state| where(state: state.to_s.upcase).order(:name) }})
      end

      it 'should stay on a single line' do
        scope = %Q{scope :my_scope, lambda{|vendor| {:include => :vendor_purchase_order, :conditions => ["purchase_orders.vendor_id = ?", vendor.id]}}}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, lambda { |vendor| includes(:vendor_purchase_order).where("purchase_orders.vendor_id = ?", vendor.id) }})
      end

      it 'should parse when a conditional is present' do
        scope = %Q{scope :my_scope, lambda{|search_term| {:conditions => ["posts.name LIKE ?", "%\#{search_term}%"]} unless search_term.blank? }}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, lambda { |search_term| where("posts.name LIKE ?", "%\#{search_term}%") unless search_term.blank? }})
      end
    end

    context "with multiple options" do
      it 'should concatinate them correctly' do
        scope = %Q{scope :my_scope, {:include => [:vendor], :conditions => "state IN ('confirmed','partially_received')"}}
        expect(ArelConverter::Translator::Scope.translate(scope)).to eq(%Q{scope :my_scope, -> { includes(:vendor).where("state IN ('confirmed','partially_received')") }})
      end
    end

  end

end


