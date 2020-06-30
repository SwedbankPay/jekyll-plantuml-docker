# frozen_string_literal: true

require 'jekyll_environment'

describe Jekyll::PlantUml::JekyllEnvironment do
  describe '#initialize' do
    let(:data_dir) { File.join(__dir__, 'data') }
    subject do
      Jekyll::PlantUml::JekyllEnvironment.new('dev', data_dir, data_dir)
    end
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
          Jekyll::PlantUml::JekyllEnvironment.new(nil, data_dir, data_dir)
        end.to raise_error(ArgumentError, 'env is nil')
      end
    end

    context 'var_dir is nil' do
      it do
        expect do
          Jekyll::PlantUml::JekyllEnvironment.new('dev', nil, data_dir)
        end.to raise_error(ArgumentError, 'var_dir is nil')
      end
    end

    context 'data_dir is nil' do
      it do
        expect do
          Jekyll::PlantUml::JekyllEnvironment.new('dev', __dir__, nil)
        end.to raise_error(ArgumentError, 'data_dir is nil')
      end
    end

    context 'data_dir does not exist' do
      it do
        expect do
          Jekyll::PlantUml::JekyllEnvironment.new('dev', __dir__, 'abc')
        end.to raise_error(ArgumentError, 'abc does not exist')
      end
    end
  end
end
