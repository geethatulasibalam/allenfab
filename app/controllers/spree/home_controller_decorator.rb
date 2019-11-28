module Spree
	HomeController.class_eval do
		autocomplete :product, :name, :full => true
	end
end