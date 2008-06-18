desc "restart ferret"
namespace :ferret do
  task :restart, :roles => :db do
    run_rake "ferret:restart"
  end

  task :start, :roles => :db do
    run_rake "ferret:start"
  end

  task :stop, :roles => :db do
    run_rake "ferret:stop"
  end

  task :rebuild, :roles => :db do
    run_rake "ferret:rebuild"
  end

  task :reindex, :roles => :db do
    run_rake "ferret:reindex"
  end
end

before "deploy:symlink", "ferret:stop"
after "deploy:symlink", "ferret:start"

