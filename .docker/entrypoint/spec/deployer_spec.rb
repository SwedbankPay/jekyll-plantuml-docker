# frozen_string_literal: true

require 'jekyll'
require 'commands/deployer'
require 'spec_jekyll_build'
require 'invoke_matcher'

describe Jekyll::PlantUml::Deployer do
  subject(:deployer) { Jekyll::PlantUml::Deployer.new(__dir__, __dir__) }

  describe '#deploy' do
    subject! { deployer.jekyll_build = Jekyll::PlantUml::SpecJekyllBuild.new }
    it { expect { deployer.deploy(false, false) }.to invoke(:process).on(subject).at_least(1).times }
  end
end
