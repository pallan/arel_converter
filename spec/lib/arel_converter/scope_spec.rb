require 'spec_helper'

describe ArelConverter::Scope do

  context 'parsing' do
    
    before(:each) do
      @converter = ArelConverter::Scope.new('/tmp')
    end

    it "work with join scopes" do
      scope = %Q{scope :outstanding, {:joins => "LEFT JOIN goods_receipts ON goods_receipts.vendor_purchase_order_line_item_id=purchase_order_line_items.id", :group => 'purchase_order_line_items.id HAVING (SUM(goods_receipts.amount_received) < purchase_order_line_items.quantity OR ISNULL(SUM(goods_receipts.amount_received))) AND purchase_order_line_items.quantity != 0'}}
      expect(@converter.process_line(scope)).to eq(%Q{scope :outstanding, -> { joins("LEFT JOIN goods_receipts ON goods_receipts.vendor_purchase_order_line_item_id=purchase_order_line_items.id").group("purchase_order_line_items.id HAVING (SUM(goods_receipts.amount_received) < purchase_order_line_items.quantity OR ISNULL(SUM(goods_receipts.amount_received))) AND purchase_order_line_items.quantity != 0") }})
    end

    it 'should handle scopes followed by a comment' do
      scope = %Q{scope :active, :conditions => "global_state_cache = 'active'" # FIXME: this one is dangerous (dvd, 09-07-2010)}
      expect(@converter.process_line(scope)).to eq(%Q{scope :active, -> { where("global_state_cache = 'active'") } # FIXME: this one is dangerous (dvd, 09-07-2010) })
    end
  end

end

