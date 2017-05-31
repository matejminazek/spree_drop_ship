require 'spec_helper'

describe Spree::Shipment do
  describe 'Scopes' do
    it '#by_supplier' do
      supplier = create(:supplier)
      stock_location1 = supplier.stock_locations.first
      stock_location2 = create(:stock_location, supplier: supplier)
      create(:shipment)
      shipment2 = create(:shipment, stock_location: stock_location1)
      create(:shipment)
      shipment4 = create(:shipment, stock_location: stock_location2)
      create(:shipment)
      shipment6 = create(:shipment, stock_location: stock_location1)

      expect(subject.class.by_supplier(supplier.id)).to match_array([shipment2, shipment4, shipment6])
    end
  end

  describe '#after_ship' do
    it 'should capture payment if balance due' do
      skip 'TODO make it so!'
    end

    it 'should track commission for shipment' do
      supplier = create(:supplier_with_commission)
      shipment = create(:shipment, stock_location: supplier.stock_locations.first)

      expect(shipment.supplier_commission.to_f).to eql(0.0)
      shipment.stub final_price_with_items: 10.0
      shipment.send(:after_ship)
      expect(shipment.reload.supplier_commission.to_f).to eql(1.5)
    end
  end

  it '#final_price_with_items' do
    shipment = build :shipment
    shipment.stub item_cost: 50.0, final_price: 5.5
    expect(shipment.final_price_with_items.to_f).to eql(55.5)
  end
end
