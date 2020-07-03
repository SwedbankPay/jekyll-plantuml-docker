# frozen_string_literal: true
require_relative '../lib/commands/jekyll_commander'

load 'includes.rb'

describe Jekyll::PlantUml::Commands::JekyllCommander do
  describe '#initialize' do
    context 'nil config' do
      it do
        expect do
          JekyllCommander.new(nil, :info)
        end.to raise_error(ArgumentError, 'Value cannot be nil')
      end
    end

    context 'empty config' do
      it do
        expect do
          JekyllCommander.new({}, :info)
        end.to raise_error(ArgumentError, 'jekyll_config cannot be empty')
      end
    end

    context 'non-hash config' do
      it do
        expect do
          JekyllCommander.new([], :info)
        end.to raise_error(ArgumentError, 'Array is not a Hash')
      end
    end
  end

  describe '#execute :build' do
    describe '_site' do
      data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'minimal')
      site_dir = File.join(data_dir, '_site')

      before(:all) do
        exec_env = ExecEnv.new('development', __dir__, data_dir)
        jekyll_config_provider = JekyllConfigProvider.new(exec_env, :info)
        jekyll_config = jekyll_config_provider.provide('build')
        jekyll_commander = JekyllCommander.new(jekyll_config, :info)
        jekyll_commander.execute('build')
      end

      subject do
        Pathname.new(site_dir)
      end

      it {
        is_expected.to be_directory
      }

      it {
        is_expected.to exist
      }

      it {
        expect(Dir.entries(subject)).to_not be_empty
      }

      describe 'index.html' do
        index_html_path = File.join(site_dir, 'index.html')
        subject { File.read(index_html_path) }

        it {
          expect(File).to exist(index_html_path)
        }

        it {
          is_expected.not_to be_empty
        }

        # TODO: Figure out a way to replicate this test outside of RSpec,
        # since setting JEKYLL_ENV=production has crazy effects on everything.
        #
        # it {
        #   is_expected.to include('https://swedbankpay.github.io/jekyll-plantuml-docker/')
        # }
      end
    end
  end

  describe '#execute :serve' do
    describe 'weird file' do
      data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'full')

      before(:all) do
        @thread = Thread.new do
          jekyll_config_provider = Jekyll::PlantUml::JekyllConfigProvider.new(data_dir)
          jekyll_config = jekyll_config_provider.provide('serve')
          jekyll_commander = Jekyll::PlantUml::Commands::JekyllCommander.new(jekyll_config)
          jekyll_commander.execute('serve')
        end
        @thread.abort_on_exception = true

        Jekyll::Commands::Serve.mutex.synchronize do
          unless Jekyll::Commands::Serve.running?
            Jekyll::Commands::Serve.run_cond.wait(Jekyll::Commands::Serve.mutex)
          end
        end
      end
      
      after(:each) do
        Jekyll::Commands::Serve.shutdown
  
        Jekyll::Commands::Serve.mutex.synchronize do
          if Jekyll::Commands::Serve.running?
            Jekyll::Commands::Serve.run_cond.wait(Jekyll::Commands::Serve.mutex)
          end
        end
      end

      it {
        expect(File).not_to exist(File.join(__dir__, '..', '0.0.0.0'))
      }
    end
  end
end
