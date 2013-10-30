require 'spec_helper'

describe ArelConverter::Scope do

  context 'parsing scopes' do
    
    before(:each) do
      @converter = ArelConverter::Scope.new('/tmp')
    end

    context 'with conditions to where' do
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
    end

    #it "work with join scopes" do
      #scope = %Q{scope :outstanding, {:joins => "LEFT JOIN goods_receipts ON goods_receipts.vendor_purchase_order_line_item_id=purchase_order_line_items.id", :group => 'purchase_order_line_items.id HAVING (SUM(goods_receipts.amount_received) < purchase_order_line_items.quantity OR ISNULL(SUM(goods_receipts.amount_received))) AND purchase_order_line_items.quantity != 0'}}
      #expect(@converter.process_line(scope)).to eq(%Q{scope :outstanding, -> { joins("LEFT JOIN goods_receipts ON goods_receipts.vendor_purchase_order_line_item_id=purchase_order_line_items.id").group("purchase_order_line_items.id HAVING (SUM(goods_receipts.amount_received) < purchase_order_line_items.quantity OR ISNULL(SUM(goods_receipts.amount_received))) AND purchase_order_line_items.quantity != 0") }})
    #end

    #it 'should handle scopes followed by a comment' do
      #scope = %Q{scope :active, :conditions => "global_state_cache = 'active'" # FIXME: this one is dangerous (dvd, 09-07-2010)}
      #expect(@converter.process_line(scope)).to eq(%Q{scope :active, -> { where("global_state_cache = 'active'") } # FIXME: this one is dangerous (dvd, 09-07-2010) })
    #end
  end

end

