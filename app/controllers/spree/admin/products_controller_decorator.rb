module Spree
  module Admin
    ProductsController.class_eval do # rubocop: disable Metrics/BlockLength
      before_filter :load_suppliers, only: %i[edit update]
      before_filter :supplier_collection, only: [:index]

      create.after :add_product_to_supplier
      custom_callback(:clone).after :add_product_to_supplier

      # Added callback hooks to clone action
      def clone
        @new = @product.duplicate

        if @new.save
          invoke_callbacks(:clone, :after)
          flash[:success] = Spree.t('notice_messages.product_cloned')
        else
          invoke_callbacks(:clone, :fails)
          flash[:error] = Spree.t('notice_messages.product_not_cloned')
        end

        redirect_to edit_admin_product_url(@new)
      end

      private

      def load_suppliers
        @suppliers = Spree::Supplier.order(:name)
      end

      # Scopes the collection to the Supplier.
      def supplier_collection
        return unless try_spree_current_user.try(:supplier?)

        if params[:q][:deleted_at_null] == '0'
          # paranoid doesn't support joins with unscoped relations
          @collection = @collection.joins("INNER JOIN spree_variants ON spree_variants.product_id = spree_products.id
            INNER JOIN spree_supplier_variants ON spree_supplier_variants.variant_id = spree_variants.id
            INNER JOIN spree_suppliers ON spree_suppliers.id = spree_supplier_variants.supplier_id
            AND (spree_suppliers.id = #{try_spree_current_user.supplier.id})")
        else
          @collection = @collection.joins(:suppliers)
                                   .where('spree_suppliers.id = ?', try_spree_current_user.supplier_id)
        end
      end

      # Newly added products by a Supplier are associated with it.
      def add_product_to_supplier
        return unless try_spree_current_user.try(:supplier?)

        # if product is cloned we need to set @new product instance supplier else user @product
        product = @new || @product
        product.add_supplier!(try_spree_current_user.supplier_id)
      end
    end
  end
end
