# frozen_string_literal: true

require 'its'
require 'includes'

describe Options do
  describe '#initialize' do
    subject { Options.new(args) }

    context 'with arguments' do
      let(:args) { ['--log-level=debug'] }

      it {
        is_expected.to have_attributes(log_level: :debug)
      }
    end

    context 'nil arguments' do
      let(:args) { nil }

      it {
        is_expected.to have_attributes(log_level: :fatal)
      }
    end

    context 'empty arguments' do
      let(:args) { [] }

      it {
        is_expected.to have_attributes(log_level: :fatal)
      }
    end
  end
end
