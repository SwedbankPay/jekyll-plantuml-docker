# frozen_string_literal: true

require 'file_not_found_error'
require 'jekyll_config_provider'

describe Jekyll::PlantUml::JekyllConfigProvider do
  describe '#get_config' do
    let(:data_dir) { File.join(__dir__, 'data') }
    subject(:jcp) { Jekyll::PlantUml::JekyllConfigProvider }

    context 'existing _config.yml' do
      subject(:config_provider) { jcp.new(data_dir) }

      it 'nil should raise' do
        expect { config_provider.get_config(nil) }.to raise_error(ArgumentError, 'jekyll_command is nil')
      end

      context 'build returns config' do
        subject { config_provider.get_config('build') }
        let(:spec_config) { File.join(data_dir, '_config.yml') }
        let(:destination) { File.join(data_dir, '_site') }

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
      subject(:config_provider) { jcp.new('non_existing_directory') }

      context 'serve returns config' do
        subject { config_provider.get_config('serve') }

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
