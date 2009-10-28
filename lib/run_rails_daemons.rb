require 'daemons'
require 'loggable'

module Daemons
  def self.run_rails(name, opts = {}, &block)
    dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
     
    daemon_options = {
      :multiple => true,
      :dir_mode => :normal,
      :dir => File.join(dir, 'tmp', 'pids'),
      :backtrace => true
    }

    daemon_options.merge!(opts)
     
    run_proc(name, daemon_options) do
      if ARGV.include?('--')
        ARGV.slice! 0..ARGV.index('--')
      else
        ARGV.clear
      end
      
      Dir.chdir dir
      Object.const_set("RAILS_ENV", ARGV.first || ENV['RAILS_ENV'] || 'development')
      require File.join('config', 'environment')

      Loggable.logger.info("Starting #{name}")
      
      block.call
    end
  end
end
     
