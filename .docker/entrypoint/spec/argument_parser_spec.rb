# frozen_string_literal: true

load 'includes.rb'

describe Jekyll::PlantUml::ArgumentParser do
  docker_image = DockerImage.new('jekyll-plantuml', 'latest', '1.2.3')
  argument_parser = ArgumentParser.new(docker_image)

  describe '#initialize' do
    subject { argument_parser }

    context 'docker_image: nil' do
      it do
        expect do
          ArgumentParser.new(nil)
        end.to raise_error(ArgumentError, "#{DockerImage} cannot be nil")
      end
    end

    context 'docker_image: not a DockerImage' do
      it do
        expect do
          ArgumentParser.new({})
        end.to raise_error(ArgumentError, "Hash is not a #{DockerImage}")
      end
    end

    it {
      is_expected.to_not be_nil
    }
  end

  describe '#parse' do
    [['--help'], ['build', '--dry-run'], ['serve', '--dry-run']].each do |args|
      context args.join(' ') do
        it do
          expect { argument_parser.parse(args) }.to raise_error(Docopt::Exit, /Usage:/)
        end
      end
    end

    context '--version' do
      it do
        expect { argument_parser.parse(['--version']) }.to raise_error(Docopt::Exit, /#{docker_image.version}/)
      end
    end

    context 'build' do
      subject { argument_parser.parse(['build']) }

      it {
        is_expected.to include('build' => true)
      }

      it {
        is_expected.to include('--dry-run' => false)
      }

      it {
        is_expected.to include('--verify' => false)
      }

      it {
        is_expected.to include('--ignore-url' => [])
      }

      it {
        is_expected.to include('--log-level' => nil)
      }
    end

    context '--ignore-url' do
      subject do
        args = ['build', '--ignore-url=https://example.com', '--ignore-url=https://example.net', '--ignore-url="%r{[/.]?page1}"']
        argument_parser.parse(args)
      end

      it {
        is_expected.to include('--ignore-url' => ['https://example.com', 'https://example.net', %r{[/.]?page1}])
      }
    end

    context '--log-level' do
      subject do
        args = ['build', '--log-level=error']
        argument_parser.parse(args)
      end

      it {
        is_expected.to include('--log-level' => 'error')
      }
    end

    context '--dry-run' do
      subject do
        args = ['deploy', '--dry-run']
        argument_parser.parse(args)
      end

      it {
        is_expected.to include('--dry-run' => true)
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
