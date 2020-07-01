# frozen_string_literal: true

require 'argument_parser'
require 'docker_image'

describe Jekyll::PlantUml::ArgumentParser do
  docker_image = Jekyll::PlantUml::DockerImage.new('jekyll-plantuml', 'latest', '1.2.3')
  argument_parser = Jekyll::PlantUml::ArgumentParser.new(docker_image)

  describe '#initialize' do
    subject { argument_parser }

    context 'docker_image: nil' do
      it do
        expect do
          Jekyll::PlantUml::ArgumentParser.new(nil)
        end.to raise_error(ArgumentError, 'docker_image cannot be nil')
      end
    end

    context 'docker_image: not a DockerImage' do
      it do
        expect do
          Jekyll::PlantUml::ArgumentParser.new({})
        end.to raise_error(ArgumentError, 'docker_image must be a DockerImage')
      end
    end

    it {
      is_expected.to_not be_nil
    }
  end

  describe '#parse' do
    ['--help', '-h'].each do |arg|
      it arg do
        expect { argument_parser.parse([arg]) }.to raise_error(Docopt::Exit, /Usage:/)
      end
    end

    it '--version' do
      expect { argument_parser.parse(['--version']) }.to raise_error(Docopt::Exit, /#{docker_image.version}/)
    end

    context 'build' do
      subject { argument_parser.parse(['build']) }

      it {
        is_expected.to include('<command>' => 'build')
      }

      it {
        is_expected.to include('--dry-run' => false)
      }

      it {
        is_expected.to include('--verify' => false)
      }
    end
  end

  describe '#help' do
    subject { argument_parser.help }

    it {
      is_expected.to include("Runs the #{docker_image.name} container's entrypoint")
    }

    it {
      is_expected.to include('Usage:')
    }

    it {
      is_expected.to include('Options:')
    }

    it {
      is_expected.to include('Commands:')
    }
  end

  describe '#usage' do
    subject { argument_parser.usage }

    it {
      is_expected.to include('Usage:')
    }

    it {
      is_expected.not_to include('Options:')
    }

    it {
      is_expected.not_to include('Commands:')
    }
  end
end
