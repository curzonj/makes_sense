## My multi stage, capistrano-ext doesn't load the stage until
#  after the deploy.rb is done. This does it before
stages = fetch(:stages, %w(staging production))
location = fetch(:stage_dir, "config/deploy")

name = ARGV.shift
if stages.include?(name)
  load "#{location}/#{name}"
  name_sym = name.to_sym
  task name_sym do
    set :stage, name.to_sym
  end
else
  abort "No stage specified. Please specify one of: #{stages.join(', ')} (e.g. `cap #{stages.first} #{ARGV.last}')"
end
