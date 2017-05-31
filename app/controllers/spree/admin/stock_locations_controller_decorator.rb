module Spree
  module Admin
    StockLocationsController.class_eval do
      create.after :set_supplier

      private

      def set_supplier
        return unless try_spree_current_user.supplier?

        @object.supplier = try_spree_current_user.supplier
        @object.save
      end
    end
  end
end
