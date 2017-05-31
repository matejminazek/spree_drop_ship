module Spree
  BaseController.class_eval do
    prepend_before_action :redirect_supplier

    private

    def redirect_supplier
      return unless %w[/admin /admin/authorization_failure].include?(request.path)
      return unless try_spree_current_user.try(:supplier)

      redirect_to '/admin/shipments'
    end
  end
end
