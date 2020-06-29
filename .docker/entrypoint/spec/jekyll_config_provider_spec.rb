# frozen_string_literal: true

require 'file_not_found_error'
require 'jekyll_config_provider'

describe Jekyll::PlantUml::JekyllConfigProvider do
  describe '#provide' do
    data_dir = File.join(__dir__, 'data')
    spec_config = File.join(data_dir, '_config.yml')
    destination = File.join(data_dir, '_site')

    context 'existing _config.yml' do
      it 'nil should raise' do
        expect do
          Jekyll::PlantUml::JekyllConfigProvider.new(data_dir).provide(nil)
        end.to raise_error(ArgumentError, 'jekyll_command is nil')
      end

      context 'build returns config' do
        before(:all) do
          jekyll_config_provider = Jekyll::PlantUml::JekyllConfigProvider.new(data_dir)
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
    end

    context 'non-existing _config.yml' do
      context 'serve returns config' do
        before(:all) do
          jekyll_config_provider = Jekyll::PlantUml::JekyllConfigProvider.new('non_existing_directory')
          @jekyll_config = jekyll_config_provider.provide('serve')
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
