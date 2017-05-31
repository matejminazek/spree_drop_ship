module Spree
  Shipment.class_eval do
    # TODO: here to fix cancan issue thinking its just Order
    belongs_to :order, class_name: 'Spree::Order', touch: true, inverse_of: :shipments
    has_many :payments, as: :payable

    scope(:by_supplier, lambda { |supplier_id|
      joins(:stock_location).where(spree_stock_locations: { supplier_id: supplier_id })
    })

    self.whitelisted_ransackable_attributes |= %w[state]

    delegate :supplier, to: :stock_location

    def display_final_price_with_items
      Spree::Money.new final_price_with_items
    end

    def final_price_with_items
      item_cost + final_price
    end

    # TODO: move commission to spree_marketplace?
    def supplier_commission_total
      ((final_price_with_items * supplier.commission_percentage / 100) + supplier.commission_flat_rate)
    end

    private

    durably_decorate :after_ship, mode: 'soft', sha: 'e8eca7f8a50ad871f5753faae938d4d01c01593d' do
      original_after_ship
      update_commission if supplier.present?
    end

    def update_commission
      update_column :supplier_commission, supplier_commission_total
    end
  end
end
