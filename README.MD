# Jekyll PlantUML

![Test Deploy][test-badge]
[![CLA assistant][cla-badge]][cla]
[![Docker Pulls][docker-pull-badge]][docker]
[![Docker Image Version (latest semver)][docker-version-badge]][docker]
[![License][license-badge]][license]
[![Dependabot Status][dependabot-badge]][dependabot]
[![Contributor Covenant][coc-badge]][coc]

This is the repositry for the [`swedbankpay/jekyll-plantuml`][docker] Docker
image. The purpose of the image is to have a shared Docker image to run
[Jekyll][jekyll] sites with [PlantUML][plantuml] support (via the
[kramdown-plantuml][kramdown-plantuml] Ruby Gem).

## Usage

To have Jekyll serve content from the current working directory, simply execute
the following:

```bash
docker run --tty --volume $(pwd):/srv/jekyll swedbankpay/jekyll-plantuml:latest
```

### Commands

The Docker image is outfitted with an [`entrypoint`][entrypoint] that allows you
to run any command inside the container. The default command is:

```bash
jekyll serve --livereload --interactive --force_polling --watch --host 0.0.0.0
```

If the default command isn't to your liking, or if you just want to do
`jekyll build`, you simply write the command you want to execute after the image
name as such:

```bash
docker run --tty --volume $(pwd):/srv/jekyll swedbankpay/jekyll-plantuml:latest jekyll build
```

#### Deploy

There is also a special `deploy` command which will execute [Git Directory
Deploy][gdd] in order to perform a `jekyll build` and then deploy the resulting
HTML to the `gh-pages` branch (by default):

```shell
docker run --tty \
    --volume $(pwd):/srv/jekyll \
    --env GIT_DEPLOY_REPO="${GIT_DEPLOY_REPO}" \
    --env GIT_DEPLOY_BRANCH="${GIT_DEPLOY_BRANCH}" \
    swedbankpay/jekyll-plantuml:latest \
    deploy
```

The `deploy` command takes the following environment variables:

##### `GIT_DEPLOY_REPO`

**Required**. The URL of the repository to deploy (`git push`) to. Must include
a [Personal Access Token][pat] in the URL as such:

```bash
https://${{ secrets.GH_PAGES_TOKEN }}@github.com/${{ github.repository }}.git
```

##### `GIT_DEPLOY_BRANCH`

**Optional**. The branch to deploy to. Default `gh-pages`.

### Volume

The Docker image exposes one volume: **`/srv/jekyll`**. Map this to the local
directory you want Jekyll to use as its source content directory for `jekyll
build`, `jekyll serve`, etc. Simply put, this is where your `.md` files are
placed.

### Configuration

While it is highly recommended to [install Jekyll][jekyll-docs] locally and
initialize a Jekyll site with `jekyll new <name>`, this is not required to
serve or convert `.md` files with `jekyll-plantuml`.

This is achieved by shipping a [default `Gemfile`][gemfile] and [default
`_config.yml`][config] with the Docker container that is used in the case that a
`Gemfile` and/or `_config.yml` file can't be found locally.

If you want a full Jekyll site with local config, custom plugins, etc., you need
to install Jekyll and initialize the folder you `build` or `serve` with it
according to [Jekyll's documentation][jekyll-docs].

## Contributing

Bug reports and pull requests are welcome on [GitHub][github]. This project is
intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [code of conduct][coc] and sign the
[contributor's license agreement][cla].

## License

The code within this repository is available as open source under the terms of
the [Apache 2.0 License][license] and the [contributor's license
agreement][cla].

[cla-badge]:            https://cla-assistant.io/readme/badge/SwedbankPay/jekyll-plantuml-docker
[cla]:                  https://cla-assistant.io/SwedbankPay/jekyll-plantuml-docker
[coc-badge]:            https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg
[coc]:                  ./CODE_OF_CONDUCT.md
[config]:               ./.docker/jekyll-plantuml/_config.yml
[dependabot-badge]:     https://api.dependabot.com/badges/status?host=github&repo=SwedbankPay/jekyll-plantuml-docker
[dependabot]:           https://dependabot.com
[docker-pull-badge]:    https://img.shields.io/docker/pulls/swedbankpay/jekyll-plantuml
[docker-version-badge]: https://img.shields.io/docker/v/swedbankpay/jekyll-plantuml
[docker]:               https://hub.docker.com/r/swedbankpay/jekyll-plantuml
[entrypoint]:           ./.docker/entrypoint
[gdd]:                  https://github.com/SwedbankPay/git-directory-deploy/
[gemfile]:              ./.docker/jekyll-plantuml/Gemfile
[github]:               https://github.com/SwedbankPay/jekyll-plantuml-docker
[jekyll-docs]:          https://jekyllrb.com/docs/
[jekyll]:               https://jekyllrb.com/
[kramdown-plantuml]:    https://github.com/SwedbankPay/kramdown-plantuml
[license-badge]:        https://img.shields.io/github/license/SwedbankPay/jekyll-plantuml-docker
[license]:              https://opensource.org/licenses/Apache-2.0
[pat]:                  https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line
[plantuml]:             https://plantuml.com/
[test-badge]:           https://github.com/SwedbankPay/jekyll-plantuml-docker/workflows/Test%20Deploy/badge.svg
