# frozen_string_literal: true

require 'its'
require 'includes'

describe Arguments do
  describe '#initialize' do
    urls = ['https://example.com', 'https://example.net']
    args = {
      'build' => true,
      'serve' => false,
      'deploy' => false,
      '--verify' => true,
      '--dry-run' => true,
      '--ignore-url' => urls,
      '--site-url' => 'https://example.org',
      '--log-level' => :debug,
      '--env' => 'stage',
      '--profile' => true,
    }
    subject { Arguments.new(args) }

    it {
      is_expected.to have_attributes({
        command: 'build',
        ignore_urls: urls,
        log_level: :debug,
        environment: 'stage',
        profile: true
      })
    }

    its(:verify?) { is_expected.to be true }
    its(:dry_run?) { is_expected.to be true }
    its(:profile?) { is_expected.to be true }
    its(:to_s) { is_expected.to eq 'build --env=stage --verify --dry-run --ignore-url=https://example.com --ignore-url=https://example.net --log-level=debug --profile' }
    its(:inspect) { is_expected.to eq args.inspect }
  end
end
