module Spree
  class SupplierAbility
    include CanCan::Ability

    def initialize(user)
      user ||= Spree.user_class.new

      return unless user.supplier

      # TODO: Want this to be inline like:
      # can [:admin, :read, :stock], Spree::Product, suppliers: { id: user.supplier_id }
      # can [:admin, :read, :stock], Spree::Product, supplier_ids: user.supplier_id
      can %i[admin manage stock], Spree::Product do |product|
        product.supplier_ids.include?(user.supplier_id)
      end
      can %i[admin index create], Spree::Product
      can %i[admin manage read ready ship], Spree::Shipment,
          order: { state: 'complete' },
          stock_location: { supplier_id: user.supplier_id }
      can %i[admin create update], :stock_items
      can :admin, Spree::Stock
      can %i[admin manage], Spree::StockItem, stock_location_id: user.supplier.stock_locations.pluck(:id)
      can %i[admin manage], Spree::StockLocation, supplier_id: user.supplier_id
      can :create, Spree::StockLocation
      can %i[admin manage], Spree::StockMovement,
          stock_item: { stock_location_id: user.supplier.stock_locations.pluck(:id) }
      can :create, Spree::StockMovement
      can %i[admin update], Spree::Supplier, id: user.supplier_id
    end
  end
end
