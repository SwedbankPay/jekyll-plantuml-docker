# frozen_string_literal: true

require 'its'
require 'includes'

describe EnvironmentVariables do
  describe '#initialize' do
    context 'missing environment variables' do
      it do
        expect { EnvironmentVariables.new }.to \
          raise_error(KeyError, 'key not found: "JEKYLL_VAR_DIR"')
      end
    end

    context 'environment variables set' do
      data_dir = File.join(__dir__, 'data')

      before(:all) do
        ENV['JEKYLL_VAR_DIR'] = data_dir
        ENV['JEKYLL_DATA_DIR'] = data_dir
      end

      after(:all) do
        ENV.delete('JEKYLL_VAR_DIR')
        ENV.delete('JEKYLL_DATA_DIR')
      end

      subject { EnvironmentVariables.new }

      it {
        is_expected.not_to be_nil
      }

      it {
        is_expected.to have_attributes(
          env: 'production',
          data_dir: data_dir,
          var_dir: data_dir,
          auth_token: nil,
          git_branch: nil,
          git_repository_url: nil,
          debug: false
        )
      }
    end
  end
end
