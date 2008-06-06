Dir[ "#{File.dirname(__FILE__)}/lib/capistrano/*.rb" ].each { |p| require p }

Capistrano::Configuration.instance.load do
  load_paths.unshift File.expand_path(File.dirname(__FILE__) + '/recipes/')

  after  "deploy:update_code", "deploy:web:disable"
  before "deploy:stop",        "deploy:web:disable"
  before "deploy:restart",     "deploy:web:disable"
  after  "deploy:restart",     "deploy:web:enable"
  after  "deploy:start",       "deploy:web:enable"

  after "deploy",              "deploy:cleanup"
  after "deploy:migrations",   "deploy:cleanup"
end
