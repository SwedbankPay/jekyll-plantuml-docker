#!/bin/bash

[ "${DEBUG:-false}" = "true" ] && set -x

bundle check || bundle install

exec bundle exec ruby entrypoint.rb
