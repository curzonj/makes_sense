
module Capistrano
  class Configuration
    def run_rake(rake_cmd,rake_path=nil)
      rake_path ||= current_path

      rake = fetch(:rake, "rake")
      trace = fetch(:debug, "false")
      rails_env = fetch(:rails_env, "production")
      cmd = "cd #{rake_path} && #{rake} #{rake_cmd}"
      cmd += " RAILS_ENV=#{rails_env}"
      cmd += " --trace" if trace == 'true'
      run cmd
    end
  end
end
