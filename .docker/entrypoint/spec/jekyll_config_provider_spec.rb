# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
require 'jekyll_config_provider'
require 'errors/file_not_found_error'

describe Jekyll::PlantUml::JekyllConfigProvider do
  include Jekyll::PlantUml

  describe '#provide' do
    data_dir = File.join(__dir__, 'data')
    spec_config = File.join(data_dir, '_config.yml')
    destination = File.join(data_dir, '_site')

    context 'existing _config.yml' do
      it 'nil should raise' do
        expect do
          exec_env = ExecEnv.new('development', __dir__, data_dir)
          jekyll_config_provider = JekyllConfigProvider.new(exec_env, :info)
          jekyll_config_provider.provide(nil)
        end.to raise_error(ArgumentError, 'jekyll_command is nil')
      end

      context 'build returns config' do
        before(:all) do
          exec_env = ExecEnv.new('development', __dir__, data_dir)
          jekyll_config_provider = JekyllConfigProvider.new(exec_env, :error)
          @jekyll_config = jekyll_config_provider.provide('build')
        end

        subject { @jekyll_config }

        it {
          is_expected.to include('config' => spec_config)
        }

        it {
          is_expected.to include('source' => data_dir)
        }

        it {
          is_expected.to include('destination' => destination)
        }

        it {
          is_expected.to include('incremental' => true)
        }
      end

      context 'serve returns config' do
        before(:all) do
          jekyll_config_provider = Jekyll::PlantUml::JekyllConfigProvider.new(data_dir)
          @jekyll_config = jekyll_config_provider.provide('serve')
        end

        subject { @jekyll_config }
        
        it {
          is_expected.to include('livereload_port' => 35_729)
        }
      end
    end

    context 'non-existing _config.yml' do
      rnd = SecureRandom.urlsafe_base64
      dir = File.join(__dir__, 'data', ".#{rnd}")

      context 'serve returns config' do
        before(:all) do
          exec_env = ExecEnv.new('development', __dir__, dir)
          jekyll_config_provider = JekyllConfigProvider.new(exec_env, :error)
          @jekyll_config = jekyll_config_provider.provide('serve')
        end

        after(:all) do
          FileUtils.rm_rf(dir) if Dir.exist? dir
        end

        subject { @jekyll_config }

        it 'should return config' do
          is_expected.to have_key('config')
          expect(subject['config']).to end_with('entrypoint/_config.default.yml')
        end

        it {
          is_expected.to include('config' => %r{entrypoint/_config.default.yml$})
        }

        it {
          is_expected.to include('host' => '0.0.0.0')
        }

        it {
          is_expected.to include('port' => '4000')
        }

        it {
          is_expected.to include('livereload' => true)
        }

        it {
          is_expected.to include('force_polling' => true)
        }

        it {
          is_expected.to include('watch' => true)
        }
      end
    end
  end
end
