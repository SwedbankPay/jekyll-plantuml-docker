# frozen_string_literal: true

RSpec::Matchers.define :be_valid_gemfile do |_meth, _expected|
  match do |actual|
    Bundler::Definition.build(actual, nil, {})
  end
end
