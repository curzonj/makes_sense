desc "restart ferret"
namespace :ferret do
  task :restart, :roles => :db do
    run_rake "ferret:restart"
  end

  task :rebuild, :roles => :db do
    run_rake "ferret:rebuild"
  end
end

before "deploy:restart", "ferret:restart"

