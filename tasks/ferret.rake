ENV['FERRET_USE_LOCAL_INDEX'] = 'true'

namespace :ferret do
  task :reindex => :load_models do
    ModelLoading.models.each do |model|
      model.rebuild_index if model.respond_to?(:aaf_configuration)
    end
  end

  task :load_models => :environment do
    # acts_as_ferret has a bug where is does't discover models
    # quite right. This solves the problem by loading the models
    # before hand
    ModelLoading.models
  end

  task :stop => :environment do
    begin
      ActsAsFerret::Remote::Server.new.send('stop')
    rescue RuntimeError => e
      if e.message == "ferret_server doesn't appear to be running"
        puts e.message
      else
        raise e
      end
    end
  end

  task :start => :load_models do
    ActsAsFerret::Remote::Server.new.send('start')
  end

  task :restart => [ :stop, :start ]
  task :rebuild => [ :stop, :reindex, :start ]
end