module MakesSense
  module GridColumns
    def derived_attributes(*cols)
      cattr_accessor :_derived_attributes
      self._derived_attributes = cols
    end
    def sort_type(attribute, type=nil)
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
    def grid_columns(*cols)
      cattr_accessor :_grid_columns
      self._grid_columns = cols
      if self.respond_to?(:aaf_configuration)
        set = {}
        cols << :id

        cols.each do |c|
          c = c.is_a?(Symbol) ? c : c.intern

          unless self.instance_methods.include?("#{c}_sort")
            instance_eval do
              define_method("#{c}_sort") do
                self.send(c)
              end
            end
          end

          unless :id == c
            # ferret auto adds the :id column and complains if
            # we try and do it, other columns can be added here
            # even if ferret adds them too (db columns) because
            # it gets merged before the c code that complains
            # about duplicates
            set[c] = {
              :store => :yes,
              :index       => :omit_norms,
              :term_vector => :with_positions_offsets
            }
          end

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

ActiveRecord::Base.extend MakesSense::GridColumns
