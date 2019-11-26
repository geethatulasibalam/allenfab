module Spree
  module Core
    module ProductFilters

      # Test for discrete option values selection
      def ProductFilters.option_with_values(option_scope, option, values)
        # get values IDs for Option with name {@option} and value-names in {@values} for use in SQL below
        option_values = Spree::OptionValue.where(:presentation => [values].flatten).joins(:option_type).where(OptionType.table_name => {:name => option}).pluck("#{OptionValue.table_name}.id")
        return option_scope if option_values.empty?
  
        option_scope = option_scope.where("#{Product.table_name}.id in (select product_id from #{Variant.table_name} v left join spree_option_values_variants ov on ov.variant_id = v.id where ov.option_value_id in (?))", option_values)
        option_scope
        puts option_scope.inspect
      end

      # multi-option scope
      Spree::Product.scope :option_any,
                         lambda { |*opts|
                           option_scope = Spree::Product.includes(:variants_including_master)
                           opts.map { |opt|
                             # opt is an array => ['option-name', [value1, value2, value3, ...]]
                             option_scope = option_with_values(option_scope, *opt)
                           }
                           option_scope
                         }
      
      # clothes size filter
      def ProductFilters.clothes_size_filter
        clothes_sizes = Spree::OptionValue.where(:option_type_id => Spree::OptionType.find_by_name!("clothes-size")).order("position").map(&:presentation).compact.uniq
        {
            :name => "Tam. Roupa",
            :scope => :option_any,
            :conds => nil,
            :option => 'clothes-size',
            :labels => clothes_sizes.map { |k| [k, k] }
        }
      end

      # hat size filter
      def ProductFilters.hat_size_filter
        hat_sizes = Spree::OptionValue.where(:option_type_id => Spree::OptionType.find_by_name!("hat-size")).order("position").map(&:presentation).compact.uniq
        {
            :name => "Tam. Chapéus",
            :scope => :option_any,
            :conds => nil,
            :option => 'hat-size',
            :labels => hat_sizes.map { |k| [k, k] }
        }
      end   

      # shoes size filter
      def ProductFilters.shoes_size_filter
        shoes_sizes = Spree::OptionValue.where(:option_type_id => Spree::OptionType.find_by_name!("shoes-size")).order("position").map(&:presentation).compact.uniq
        {
            :name => "Tam. Sapatos",
            :scope => :option_any,
            :conds => nil,
            :option => 'shoes-size',
            :labels => shoes_sizes.map { |k| [k, k] }
        }
      end 
      # color filter
      def ProductFilters.color_filter
        colors = Spree::OptionValue.where(:option_type_id => Spree::OptionType.find_by_name("color")).order("position").map(&:presentation).compact.uniq
        {
            :name => "Cor",
            :scope => :option_any,
            :conds => nil,
            :option => 'color',
            :labels => colors.map { |k| [k, k] }
        }
      end

      # price range scope
      Spree::Product.add_search_scope :price_range_any do |*opts|
        conds = opts.map {|o| Spree::Core::ProductFilters.price_filter[:conds][o]}.reject { |c| c.nil? }
        scope = conds.shift
        conds.each do |new_scope|
          scope = scope.or(new_scope)
        end
        Spree::Product.joins(master: :default_price).where(scope)
      end

      def ProductFilters.format_price(amount)
        Spree::Money.new(amount)
      end      

      # price filter
      def ProductFilters.price_filter
        v = Spree::Price.arel_table
        conds = [ [ Spree.t(:under_price, price: format_price(150))   , v[:amount].lteq(150)],
                  [ "#{format_price(150)} - #{format_price(200)}"      , v[:amount].in(150..200)],
                  [ "#{format_price(200)} - #{format_price(250)}"      , v[:amount].in(200..250)],
                  [ "#{format_price(250)} - #{format_price(300)}"      , v[:amount].in(250..300)],
                  [ Spree.t(:or_over_price, price: format_price(300)) , v[:amount].gteq(300)]]
        {
          name:   Spree.t(:price_range),
          scope:  :price_range_any,
          conds:  Hash[*conds.flatten],
          labels: conds.map { |k,v| [k, k] }
        }
      end

      ##brand filter
      Spree::Product.add_search_scope :brand_any do |*opts|
        filter = ProductFilters.brand_filter(@@taxon)
        conds = opts.map {|o| filter[:conds][o]}.reject { |c| c.nil? }
        scope = conds.shift
        conds.each do |new_scope|
          scope = scope.or(new_scope)
        end
        Spree::Product.with_property('brand').where(scope)
      end


      def ProductFilters.brand_filter(taxon = nil)
        taxon ||= Spree::Taxonomy.first.root
        @@taxon = taxon

        property = Spree::Property.find_by(name: 'brand')

        scope = Spree::ProductProperty.where(property: property).
           joins(product: :taxons).
           where("#{Spree::Taxon.table_name}.id" => [taxon] + taxon.descendants)

        rows = scope.pluck(:value).uniq

        pp = Spree::ProductProperty.arel_table

        conds = Hash[*rows.map { |b| [b, pp[:value].eq(b)] }.flatten]

        {
          name:   'Brand',
          scope:  :brand_any,
          conds:  conds,
          labels: rows.sort.map { |k| [k, k] }
        }
      end

    end
  end
end
