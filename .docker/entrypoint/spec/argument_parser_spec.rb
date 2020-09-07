# frozen_string_literal: true

require 'includes'

describe ArgumentParser do
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
    subject { argument_parser.parse(args) }

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
      let(:args) { ['build'] }

      it {
        is_expected.to have_attributes(
          {
            command: 'build',
            ignore_urls: [],
            log_level: nil,
            environment: nil,
            dry_run?: false,
            verify?: false,
            profile?: false
          }
        )
      }

      context '--ignore-url' do
        let(:args) { ['build', '--ignore-url=https://example.com', '--ignore-url=https://example.net', '--ignore-url="%r{[/.]?page1}"'] }
  
        it {
          is_expected.to have_attributes(ignore_urls:  ['https://example.com', 'https://example.net', %r{[/.]?page1}])
        }
      end
  
      context '--log-level' do
        let(:args) { ['build', '--log-level=error'] }

        it {
          is_expected.to have_attributes(log_level: 'error')
        }
      end  

      context '--env' do
        let(:args) { ['build', '--env=production'] }

        it {
          is_expected.to have_attributes(environment: 'production')
        }
      end

      context '--profile' do
        let(:args) { ['build', '--profile']}

        it {
          is_expected.to have_attributes(profile: true)
        }
      end
    end

    describe 'deploy' do
      context '--dry-run' do
        let(:args) { ['deploy', '--dry-run'] }

        it {
          is_expected.to have_attributes(dry_run?: true)
        }
      end
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
