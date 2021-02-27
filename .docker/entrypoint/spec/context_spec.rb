# frozen_string_literal: true

require 'its'
require 'includes'

describe Context do
  data_dir = File.join(__dir__, 'data')

  describe '#initialize' do
    let(:configuration) { nil }

    subject {
      context = Context.new('dev', data_dir, data_dir)
      context.configuration = configuration unless configuration.nil?
      context
    }

    it {
      is_expected.not_to be_nil
    }

    it {
      is_expected.to have_attributes(
        env: 'dev',
        var_dir: data_dir,
        data_dir: data_dir,
        configuration: nil,
        auth_token: nil,
        git_branch: nil,
        git_repository_url: nil,
        debug: false
      )
    }

    its(:arguments) { is_expected.to be_a Arguments }
    its(:git_repository_url) { is_expected.to be_nil }

    context 'env is nil' do
      it { expect { Context.new(nil, data_dir, data_dir) }.to raise_error(ArgumentError, 'String cannot be nil') }
    end

    context 'env is empty' do
      it { expect { Context.new('', data_dir, data_dir) }.to raise_error(ArgumentError, 'String cannot be empty') }
    end

    context 'var_dir is nil' do
      it { expect { Context.new('dev', nil, data_dir) }.to raise_error(ArgumentError, 'String cannot be nil') }
    end

    context 'var_dir is empty' do
      it { expect { Context.new('dev', '', data_dir) }.to raise_error(ArgumentError, 'String cannot be empty') }
    end

    context 'data_dir is nil' do
      it { expect { Context.new('dev', __dir__, nil) }.to raise_error(ArgumentError, 'String cannot be nil') }
    end

    context 'data_dir is empty' do
      it { expect { Context.new('dev', __dir__, '') }.to raise_error(ArgumentError, 'String cannot be empty') }
    end

    context 'with configuration' do
      let(:configuration) {
        cfg = Jekyll.configuration
        cfg['repository'] = 'Acme/bomb'
        cfg
      }
      its(:git_repository_url) { is_expected.to eq 'https://github.com/Acme/bomb' }
    end
  end

  describe '#from_environment' do
    context 'missing environment variables' do
      it { expect { Context.from_environment }.to raise_error(KeyError, 'key not found: "JEKYLL_DATA_DIR"') }
    end

    context 'environment variables set' do
      include_context "env_helper"

      auth_token = 'SECRET_TOKEN'
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

      subject { Context.from_environment }

      it {
        is_expected.not_to be_nil
      }

      it {
        is_expected.to have_attributes(
          env: 'production',
          var_dir: data_dir,
          data_dir: data_dir,
          configuration: nil,
          auth_token: auth_token,
          git_branch: branch,
          git_repository_url: repo,
          debug: true
        )
      }

      its(:arguments) { is_expected.to be_a Arguments }
    end
  end
end
