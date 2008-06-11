module ModelLoading
  def self.models
    unless @model_loading_cache
      @model_loading_cache = []

      Dir[RAILS_ROOT + "/app/models/*.rb"].each do |file|
        klass = Object.const_get(File.basename(file, ".rb").camelize)
        if !klass.nil? and
           klass.is_a?(Class) and
           klass.respond_to?(:base_class) and
           klass.base_class.superclass == ActiveRecord::Base

          @model_loading_cache << klass
        end
      end
    end

    @model_loading_cache
  end

  def self.get_model(name)
    model = Object.const_get(name.singularize.camelize)
    unless model.is_a?(Class) and
           model.respond_to?(:base_class) and
           model.base_class.superclass == ActiveRecord::Base
      raise "Bad name in dynamic model loading" 
    end

    return model
  end
end

