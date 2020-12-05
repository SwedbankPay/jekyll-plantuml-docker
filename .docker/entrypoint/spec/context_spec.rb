# frozen_string_literal: true

require 'its'
require 'includes'

describe Context do
  data_dir = File.join(__dir__, 'data')

  describe '#initialize' do
    subject { Context.new('dev', data_dir, data_dir) }

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

    its(:arguments) { is_expected.to_not be_nil }

    context 'env is nil' do
      it do
        expect do
          Context.new(nil, data_dir, data_dir)
        end.to raise_error(ArgumentError, 'String cannot be nil')
      end
    end

    context 'env is empty' do
      it do
        expect do
          Context.new('', data_dir, data_dir)
        end.to raise_error(ArgumentError, 'String cannot be empty')
      end
    end

    context 'var_dir is nil' do
      it do
        expect do
          Context.new('dev', nil, data_dir)
        end.to raise_error(ArgumentError, 'String cannot be nil')
      end
    end

    context 'var_dir is empty' do
      it do
        expect do
          Context.new('dev', '', data_dir)
        end.to raise_error(ArgumentError, 'String cannot be empty')
      end
    end

    context 'data_dir is nil' do
      it do
        expect do
          Context.new('dev', __dir__, nil)
        end.to raise_error(ArgumentError, 'String cannot be nil')
      end
    end

    context 'data_dir is empty' do
      it do
        expect do
          Context.new('dev', __dir__, '')
        end.to raise_error(ArgumentError, 'String cannot be empty')
      end
    end
  end

  describe '#from_environment' do
    context 'missing environment variables' do
      it do
        expect { Context.from_environment }.to \
          raise_error(KeyError, 'key not found: "JEKYLL_VAR_DIR"')
      end
    end

    context 'environment variables set' do
      before(:all) do
        ENV['JEKYLL_VAR_DIR'] = data_dir
        ENV['JEKYLL_DATA_DIR'] = data_dir
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
          auth_token: nil,
          git_branch: nil,
          git_repository_url: nil,
          debug: false
        )
      }

      its(:arguments) { is_expected.to_not be_nil }
    end
  end
end
