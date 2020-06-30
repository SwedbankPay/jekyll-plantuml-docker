# frozen_string_literal: true

describe Jekyll::PlantUml::Commands::JekyllCommander do
  describe '#initialize' do
    context 'nil config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::JekyllCommander.new(nil)
        end.to raise_error(ArgumentError, 'jekyll_config cannot be nil')
      end
    end

    context 'empty config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::JekyllCommander.new({})
        end.to raise_error(ArgumentError, 'jekyll_config cannot be empty')
      end
    end

    context 'non-hash config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::JekyllCommander.new([])
        end.to raise_error(ArgumentError, 'jekyll_config must be a hash')
      end
    end
  end

  describe '#execute :build' do
    describe '_site' do
      data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'minimal')
      site_dir = File.join(data_dir, '_site')

      before(:all) do
        jekyll_config_provider = Jekyll::PlantUml::JekyllConfigProvider.new(data_dir)
        jekyll_config = jekyll_config_provider.provide('build')
        jekyll_commander = Jekyll::PlantUml::Commands::JekyllCommander.new(jekyll_config)
        jekyll_commander.execute('build')
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

        it {
          is_expected.to include('https://swedbankpay.github.io/jekyll-plantuml-docker/')
        }
      end
    end
  end
end
