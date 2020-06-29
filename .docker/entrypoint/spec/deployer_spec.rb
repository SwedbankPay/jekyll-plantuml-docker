# frozen_string_literal: true

require 'jekyll'
require 'commands/deployer'
require 'spec_jekyll_build'
require 'matchers/invoke_matcher'

describe Jekyll::PlantUml::Deployer do
  subject(:deployer) do
    data_dir = File.join(__dir__, 'data')
    Jekyll::PlantUml::Deployer.new(data_dir, data_dir)
  end

  describe '#deploy' do
    subject! { deployer.jekyll_build = Jekyll::PlantUml::SpecJekyllBuild.new }
    it { expect { deployer.deploy(false, false) }.to invoke(:process).on(subject).at_least(1).times }
  end
end
