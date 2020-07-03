# frozen_string_literal: true

load 'includes.rb'

describe Jekyll::PlantUml::ExecEnv do
  describe '#initialize' do
    let(:data_dir) { File.join(__dir__, 'data') }
    subject { ExecEnv.new('dev', data_dir, data_dir) }

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
          ExecEnv.new(nil, data_dir, data_dir)
        end.to raise_error(ArgumentError, 'env is nil')
      end
    end

    context 'var_dir is nil' do
      it do
        expect do
          ExecEnv.new('dev', nil, data_dir)
        end.to raise_error(ArgumentError, 'var_dir is nil')
      end
    end

    context 'data_dir is nil' do
      it do
        expect do
          ExecEnv.new('dev', __dir__, nil)
        end.to raise_error(ArgumentError, 'data_dir is nil')
      end
    end
  end
end
