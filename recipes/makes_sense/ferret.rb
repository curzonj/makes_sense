desc "restart ferret"
namespace :ferret do
  task :restart, :roles => :db do
    run_rake "ferret:restart"
  end

  task :rebuild, :roles => :db do
    run_rake "ferret:rebuild"
  end

  task :reindex, :roles => :db do
    run_rake "ferret:reindex"
  end
end

before "deploy:restart", "ferret:rebuild"

