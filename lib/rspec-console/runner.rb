class RSpecConsole::Runner
  def self.reset(args)
    require 'rspec/core'

    if Gem.loaded_specs['rspec-core'].version < Gem::Version.new('2.9.10')
      raise 'Please use RSpec 2.9.10 or later'
    end

    ::RSpec::Core::Runner.disable_autorun!
    ::RSpec::Core::Configuration.class_eval { define_method(:command) { 'rspec' } }
    ::RSpec.reset

    self.config_cache.cache do
      ::RSpec.configure do |config|
        config.output_stream = STDOUT
        config.color_enabled = true
      end

      require "./spec/spec_helper"
    end
  end

  def self._run(args)
    reset(args)
    ::RSpec::Core::CommandLine.new(args).run(STDERR, STDOUT)
  end

  def self.run(args)
    if defined?(Rails)
      require 'rails-env-switcher'
      RailsEnvSwitcher.with_env('test', :reload => true) { _run(args) }
    else
      _run(args)
    end
  end

  def self.config_cache
    @config_cache ||= RSpecConsole::ConfigCache.new
  end
end
