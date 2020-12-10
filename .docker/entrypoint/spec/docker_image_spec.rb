# frozen_string_literal: true

require 'its'
require 'includes'

describe DockerImage do
  image_name = 'jekyll-plantuml'
  image_tag = 'latest'
  image_version = '1.2.3'
  fqn = 'jekyll-plantuml:latest'

  subject(:docker_image) { DockerImage.new(image_name, image_tag, image_version) }
  subject { docker_image }

  describe '#initialize' do
    it {
      is_expected.not_to be_nil
    }

    it {
      is_expected.to have_attributes(
        name: image_name,
        tag: image_tag,
        version: image_version,
        fqn: fqn
      )
    }

    context 'name is nil' do
      it do
        expect do
          DockerImage.new(nil, 'latest', '1.2.3')
        end.to raise_error(ArgumentError, 'String cannot be nil')
      end
    end

    context 'tag is nil' do
      it do
        expect do
          DockerImage.new('jekyll-plantuml', nil, '1.2.3')
        end.to raise_error(ArgumentError, 'String cannot be nil')
      end
    end

    context 'version is nil' do
      it do
        expect do
          DockerImage.new('jekyll-plantuml', 'latest', nil)
        end.to raise_error(ArgumentError, 'String cannot be nil')
      end
    end
  end

  describe '#to_s' do
    its(:to_s) {
      is_expected.to eq('jekyll-plantuml:latest')
    }
  end

  describe '#from_environment' do
    include_context "env_helper"

    before(:all) do
      env({
        'JEKYLL_VAR_DIR' => __dir__,
        'JEKYLL_DATA_DIR' => __dir__,
        'DOCKER_IMAGE_NAME' => image_name,
        'DOCKER_IMAGE_TAG' => image_tag,
        'DOCKER_IMAGE_VERSION' => image_version
      })
    end

    subject { DockerImage.from_environment }

    it {
      is_expected.to have_attributes(
        name: image_name,
        tag: image_tag,
        version: image_version,
        fqn: fqn
      )
    }
  end
end
