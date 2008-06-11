module ActiveRecord
  class Base
    def self.derived_attributes(*cols)
      cattr_accessor :_derived_attributes
      self._derived_attributes = cols
    end
    def self.sort_type(attribute, type=nil)
      @ferret_sort_types ||= {}

      if type.nil?
        c = self.columns_hash
        type = c[attribute].nil? ? :string : c[attribute].type
        type = :string unless [:integer, :float, :string, :auto, :score , :doc_id].include?(type)
        type = @ferret_sort_types[attribute.to_s] unless @ferret_sort_types[attribute.to_s].nil?

        type
      else
        @ferret_sort_types[attribute.to_s] = type
      end
    end
    def self.grid_columns(*cols)
      cattr_accessor :_grid_columns
      self._grid_columns = cols
      if self.respond_to?(:aaf_configuration)

        set = {
         :id_sort => {
            :store => :yes,
            :index       => :untokenized_omit_norms,
            :term_vector => :with_positions_offsets
          }
        }
        cols.each do |c|
          c = c.is_a?(Symbol) ? c : c.intern

          unless self.instance_methods.include?("#{c}_sort")
            instance_eval do
              define_method("#{c}_sort") do
                self.send(c)
              end
            end
          end

          set[c] = {
            :store => :yes,
            :index       => :omit_norms,
            :term_vector => :with_positions_offsets
          }
          set["#{c}_sort".intern] = {
            :store => :yes,
            :index       => :untokenized_omit_norms,
            :term_vector => :with_positions_offsets
          }
        end

        self.add_fields(set)
        aaf_configuration[:ferret][:default_field] = aaf_configuration[:ferret_fields].keys.select do |f| 
          aaf_configuration[:ferret_fields][f][:index] != :untokenized && aaf_configuration[:ferret_fields][f][:index] != :untokenized_omit_norms
        end
      end
    end
  end
end
