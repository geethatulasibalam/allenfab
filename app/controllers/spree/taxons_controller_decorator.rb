module Spree
	TaxonsController.class_eval do
		# binding.pry
		helper_method :sorting_param
		alias_method :old_show, :show
		def show
     	old_show
			@products = @products.reorder('').send(sorting_scope) if params[:sorting].present?
		end
		def sorting_param
			params[:sorting].try(:to_sym) || default_sorting
		end
		private
			def default_sorting
				:ascend_by_mater_price
			end
			def sorting_scope
				allowed_sortings.include?(sorting_param)? sorting_param : default_sorting
			end
			def allowed_sortings
				[:ascend_by_master_price,:descend_by_master_price,:ascend_by_updated_at]
			end
	end
end