class AppConfig
  class << self
    def get(var, default=nil)
      config_data[var.to_s] || default
    end

    def reload!
      @cached_config_data = nil
    end
     
    private
    def config_data 
      unless @cached_config_data
        file = File.read("#{RAILS_ROOT}/config/app_config.yml")
        config = ERB.new(file)
        @cached_config_data = YAML.load(config.result)
      end

      @cached_config_data
    end
  end
end
