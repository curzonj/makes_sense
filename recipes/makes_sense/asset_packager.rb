desc "Merge javascript and css files"
task :build_assets, :roles => :web do
  run_rake "asset:packager:build_all"
end

after "deploy:upload", "build_assets"
after "deploy:symlink", "build_assets"
