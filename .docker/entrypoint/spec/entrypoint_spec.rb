# frozen_string_literal: true

require 'includes'

describe Entrypoint do
  describe '#initialize' do
    data_dir = File.join(__dir__, 'data')

    context 'with arguments' do
      subject do
        Entrypoint.new(
          Context.new('dev', data_dir, data_dir),
          DockerImage.new('jekyll-plantuml', 'latest', '1.2.3')
        )
      end

      it {
        is_expected.not_to be_nil
      }

      describe '#execute' do
        it { expect { subject.execute }.to_not raise_error }
      end
    end

    context 'from environment variables' do
      include_context 'env_helper'

      before(:all) {
        env({
          'JEKYLL_VAR_DIR' => data_dir,
          'JEKYLL_DATA_DIR' => data_dir,
          'GITHUB_BRANCH' => 'branch',
          'GITHUB_REPOSITORY_URL' => 'repo',
          'DOCKER_IMAGE_NAME' => 'img',
          'DOCKER_IMAGE_TAG' => 'tag',
          'DOCKER_IMAGE_VERSION' => '1.0'
        })
      }

      subject { Entrypoint.new }

      it {
        is_expected.not_to be_nil
      }
    end
  end
end
