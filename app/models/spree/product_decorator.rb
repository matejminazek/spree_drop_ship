module Spree
  Product.class_eval do
    has_many :suppliers, through: :master

    def add_supplier!(supplier_or_id)
      supplier = supplier_or_id.is_a?(Spree::Supplier) ? supplier_or_id : Spree::Supplier.find(supplier_or_id)
      populate_for_supplier! supplier if supplier
    end

    def add_suppliers!(supplier_ids)
      Spree::Supplier.where(id: supplier_ids).each do |supplier|
        populate_for_supplier! supplier
      end
    end

    def remove_supplier!(supplier_or_id)
      supplier = supplier_or_id.is_a?(Spree::Supplier) ? supplier_or_id : Spree::Supplier.find(supplier_or_id)
      remove_for_supplier! supplier if supplier
    end

    # Returns true if the product has a drop shipping supplier.
    def supplier?
      suppliers.present?
    end

    # overrides for has_many :suppliers helper methods for escaping ActiveRecord::HasManyThroughNestedAssociations error
    def supplier_ids
      suppliers.pluck(:id)
    end

    def supplier_ids=(new_supplier_ids)
      supplier_ids.each do |supplier_id|
        remove_supplier!(supplier_id) unless supplier_id.to_s.in?(new_supplier_ids)
      end
      add_suppliers!(new_supplier_ids)
    end

    private

    def populate_for_supplier!(supplier)
      variants_including_master.each do |variant|
        unless variant.suppliers.pluck(:id).include?(supplier.id)
          variant.suppliers << supplier
          supplier.stock_locations.each { |location| location.set_up_stock_item(variant) }
        end
      end
    end

    def remove_for_supplier!(supplier)
      variants_including_master.each do |variant|
        if variant.suppliers.pluck(:id).include?(supplier.id)
          variant.suppliers.destroy(supplier.id)
          supplier.stock_locations.each { |location| location.stock_items.where(variant_id: variant.id).destroy_all }
        end
      end
    end
  end
end
