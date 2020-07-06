# frozen_string_literal: true

require 'includes'

describe JekyllBuilder do
  describe '#initialize' do
    context 'nil config' do
      it do
        expect do
          JekyllBuilder.new(nil, :info)
        end.to raise_error(ArgumentError, 'Hash cannot be nil')
      end
    end

    context 'empty config' do
      it do
        expect do
          JekyllBuilder.new({}, :info)
        end.to raise_error(ArgumentError, 'Hash cannot be empty')
      end
    end

    context 'non-hash config' do
      it do
        expect do
          JekyllBuilder.new([], :info)
        end.to raise_error(ArgumentError, 'Array is not a Hash')
      end
    end
  end

  describe '#execute :build' do
    describe '_site' do
      data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'minimal')
      site_dir = File.join(data_dir, '_site')

      before(:all) do
        context = ExecEnv.new('development', __dir__, data_dir)
        jekyll_config_provider = JekyllConfigProvider.new(context, :error)
        jekyll_config = jekyll_config_provider.provide('build')
        jekyll_builder = JekyllBuilder.new(jekyll_config, :error)
        jekyll_builder.execute
      end

      subject do
        Pathname.new(site_dir)
      end

      it {
        is_expected.to be_directory
      }

      it {
        is_expected.to exist
      }

      it {
        expect(Dir.entries(subject)).to_not be_empty
      }

      describe 'index.html' do
        index_html_path = File.join(site_dir, 'index.html')
        subject { File.read(index_html_path) }

        it {
          expect(File).to exist(index_html_path)
        }

        it {
          is_expected.not_to be_empty
        }
      end
    end
  end
end
