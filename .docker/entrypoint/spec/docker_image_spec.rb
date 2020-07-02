# frozen_string_literal: true

require 'docker_image'

DockerImage = Jekyll::PlantUml::DockerImage

describe DockerImage do
  subject(:docker_image) { DockerImage.new('jekyll-plantuml', 'latest', '1.2.3') }
  subject { docker_image }

  describe '#initialize' do
    it {
      is_expected.not_to be_nil
    }
    it {
      is_expected.to have_attributes(
        name: 'jekyll-plantuml',
        tag: 'latest',
        version: '1.2.3',
        fqn: 'jekyll-plantuml:latest'
      )
    }

    context 'name is nil' do
      it do
        expect do
          DockerImage.new(nil, 'latest', '1.2.3')
        end.to raise_error(ArgumentError, 'name is nil')
      end
    end

    context 'tag is nil' do
      it do
        expect do
          DockerImage.new('jekyll-plantuml', nil, '1.2.3')
        end.to raise_error(ArgumentError, 'tag is nil')
      end
    end

    context 'version is nil' do
      it do
        expect do
          DockerImage.new('jekyll-plantuml', 'latest', nil)
        end.to raise_error(ArgumentError, 'version is nil')
      end
    end
  end

  describe '#to_s' do
    subject { docker_image.to_s }
    it {
      expect(subject.to_s).to eq('jekyll-plantuml:latest')
    }
  end
end
