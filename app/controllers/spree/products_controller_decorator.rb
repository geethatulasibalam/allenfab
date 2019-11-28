module Spree
	ProductsController.class_eval do
		autocomplete :taxon, :name, :full => true
	end
end