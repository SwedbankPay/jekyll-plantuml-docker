# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'test'
  spec.version       = '1.0.0'
  spec.authors       = ['Swedbank Pay']
  spec.email         = ['opensource@swedbankpay.com']

  spec.summary       = 'Gemspec test'
  spec.homepage      = 'https://github.com/SwedbankPay/jekyll-plantuml'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(/^(assets|_layouts|_includes|_sass|LICENSE|README)/i) }

  spec.add_runtime_dependency 'jekyll', '>= 3.7', '< 5.0'

  spec.add_development_dependency 'bundler'
end
