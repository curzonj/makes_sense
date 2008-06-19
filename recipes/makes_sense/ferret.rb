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

  desc "Preserve ferret index" 
  task :link_index, :roles => :db do
    run <<-EOF
      ln -s #{shared_path}/index #{latest_release}/index
    EOF
  end
end

after "deploy:update_code", "ferret:link_index"
before "deploy:symlink", "ferret:stop"
after "deploy:symlink", "ferret:start"

