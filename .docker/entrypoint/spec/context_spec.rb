# frozen_string_literal: true

require 'includes'

describe Context do
  describe '#initialize' do
    let(:data_dir) { File.join(__dir__, 'data') }
    subject { Context.new('dev', data_dir, data_dir) }

    it {
      is_expected.not_to be_nil
    }

    it {
      is_expected.to have_attributes(
        env: 'dev',
        var_dir: data_dir,
        data_dir: data_dir
      )
    }

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
end
