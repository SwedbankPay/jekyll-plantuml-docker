JEKYLL_VAR_DIR = ENV.fetch("JEKYLL_VAR_DIR")
JEKYLL_ENV = ENV.fetch("JEKYLL_ENV", "production")

unless File.file?(File.join(Dir.pwd, "Gemfile"))
  default_gemfile = File.join(JEKYLL_VAR_DIR, "Gemfile")
  puts "No Gemfile found. Using default: #{default_gemfile}"
  ENV["BUNDLE_GEMFILE"] = default_gemfile
end

unless File.file?(File.join(Dir.pwd, "_config.yml"))
  default_config_file = File.join(JEKYLL_VAR_DIR, "_config.default.yml")
  puts "No _config.yml found. Using default: ${default_config_file}"
end

if ARGV.length == 0
  puts "Running default command 'jekyll serve' (JEKYLL_ENV: #{JEKYLL_ENV})..."

  if default_config_file
    exec("bundle exec jekyll serve --config #{default_config_file} --livereload --incremental --force_polling --watch --host 0.0.0.0")
  else
    exec("bundle exec jekyll serve --livereload --incremental --force_polling --watch --host 0.0.0.0")
  end
elsif ARGV[0] == "deploy"
  puts "Deploying..."
  deploy_config_file = File.join(JEKYLL_VAR_DIR, "_config.deploy.yml")

  if default_config_file
    system({ "JEKYLL_ENV" => "production" }, "bundle exec jekyll build --verbose --config #{default_config_file},#{deploy_config_file}")
  else
    config_files = Dir.glob("_config.y*ml")
    config_files_string = config_files.join(",")
    system({ "JEKYLL_ENV" => "production" }, "bundle exec jekyll build --verbose --config #{config_files_string},#{deploy_config_file}")
  end

  exec("/usr/jekyll/bin/deploy.sh --verbose")
elsif ARGV[0] == "jekyll"
  puts "Running Jekyll command '${*:2}' (JEKYLL_ENV: ${JEKYLL_ENV})..."

  # If the default_config_file is assigned and the jekyll command supports '--config',
  # apply the default config by performing some positional argument magic.
  if default_config_file #" ] && bundle exec jekyll "$2" --help | grep '\-\-config' > /dev/null; then
    exec("bundle exec jekyll $2 --config $default_config_file ${@:3}")
  else
    exec("bundle exec jekyll ${@:2}")
  end
else
  puts "Running '$*' (JEKYLL_ENV: ${JEKYLL_ENV})..."
  exec "$@"
end
