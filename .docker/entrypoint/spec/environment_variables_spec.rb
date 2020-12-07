# frozen_string_literal: true

require 'its'
require 'includes'

describe EnvironmentVariables do
  describe '#initialize' do
    include_context 'env_helper'

    context 'missing environment variables' do
      before(:all) do
        env({
          'JEKYLL_VAR_DIR' => :undefined,
          'JEKYLL_DATA_DIR' => :undefined,
        })
      end

      it do
        expect { EnvironmentVariables.new }.to \
          raise_error(KeyError, 'key not found: "JEKYLL_DATA_DIR"')
      end
    end

    context 'environment variables set' do
      data_dir = File.join(__dir__, 'data')
      auth_token = 'VERY_SECRET'
      branch = 'my_favorite_branch'
      repo = 'https://example.com/SwedbankPay/my_favorite_repo'

      before(:all) do
        env({
          'JEKYLL_VAR_DIR' => data_dir,
          'JEKYLL_DATA_DIR' => data_dir,
          'JEKYLL_GITHUB_TOKEN' => auth_token,
          'GITHUB_BRANCH' => branch,
          'GITHUB_REPOSITORY_URL' => repo,
          'DEBUG' => true
        })
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
          auth_token: auth_token,
          git_branch: branch,
          git_repository_url: repo,
          debug: true
        )
      }
    end
  end
end
