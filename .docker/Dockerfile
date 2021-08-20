FROM ruby:2.7.4

ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    GEM_HOME="/usr/gem" \
    JEKYLL_DATA_DIR="/srv/jekyll" \
    JEKYLL_VAR_DIR="/var/jekyll" \
    DRAFTS=false \
    FORCE_POLLING=false \
    VERBOSE=false \
    DOCKER_IMAGE_NAME="swedbankpay/jekyll-plantuml"

ENV BUNDLE_HOME="$GEM_HOME" \
    BUNDLE_APP_CONFIG="$GEM_HOME" \
    BUNDLE_PATH="$GEM_HOME" \
    GEM_BIN="$GEM_HOME/bin" \
    GEM_PATH="$GEM_HOME" \
    GIT_DEPLOY_DIR="${JEKYLL_DATA_DIR}/_site" \
    PATH="${GEM_BIN}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Create all folders needed by RubyGems, Bundler, etc.
RUN addgroup --system --gid 1000 jekyll && \
    adduser --system --gid 1000 jekyll && \
    mkdir -p $JEKYLL_VAR_DIR && \
    mkdir -p $JEKYLL_DATA_DIR

COPY .docker/apt.json /tmp/apt.json

RUN apt-get clean && \
    apt-get update && \
    apt-get --no-install-recommends install -y jq && \
    jq -r 'to_entries | .[] | .key + "=" + .value' /tmp/apt.json | xargs apt-get install -y --no-install-recommends && \
    rm /tmp/apt.json && \
    apt-get purge -y jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Europe/Oslo" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    TZ=Europe/Oslo \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US

RUN gem update --system && gem install --force bundler

COPY .dockerignore ${JEKYLL_VAR_DIR}/
COPY --chown=jekyll:jekyll .docker/entrypoint ${JEKYLL_VAR_DIR}/entrypoint
RUN ${JEKYLL_VAR_DIR}/entrypoint/sh/delete_ignored_files.sh ${JEKYLL_VAR_DIR}/entrypoint

RUN bundle config build --use-system-libraries && \
    bundle config build.jekyll --use-system-libraries && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle config set system 'true' && \
    bundle config set clean 'true' && \
    bundle install \
        --gemfile="${JEKYLL_VAR_DIR}/entrypoint/Gemfile" \
        --jobs=4

# Clean up cache folders, as they aren't needed in a Docker container.
RUN rm -rf /root/.gem && \
    rm -rf /home/jekyll/.gem && \
    rm -rf $BUNDLE_HOME/cache && \
    rm -rf $GEM_HOME/cache

# Make sure jekyll:jekyll owns everything.
RUN chown -R jekyll:jekyll $JEKYLL_DATA_DIR && \
    chown -R jekyll:jekyll $JEKYLL_VAR_DIR && \
    chown -R jekyll:jekyll $BUNDLE_HOME

ADD --chown=jekyll:jekyll \
    https://github.com/SwedbankPay/git-directory-deploy/raw/1.0.4/deploy.sh \
    ${JEKYLL_VAR_DIR}/deploy.sh
RUN chmod +x ${JEKYLL_VAR_DIR}/deploy.sh

VOLUME  /srv/jekyll
WORKDIR /srv/jekyll

EXPOSE 35729
EXPOSE 4000

ARG TAG
ARG SHA
ARG DATE
ARG VERSION

RUN \
    # Ensure that the build arguments are set and not empty.
    : "${TAG:?Build argument 'TAG' is missing or empty.}" \
    : "${SHA:?Build argument 'SHA' is missing or empty.}" \
    : "${DATE:?Build argument 'DATE' is missing or empty.}" \
    : "${VERSION:?Build argument 'VERSION' is missing or empty.}"

ENV DOCKER_IMAGE_TAG=$TAG
ENV DOCKER_IMAGE_VERSION=$VERSION

LABEL org.label-schema.build-date="${DATE}" \
      org.label-schema.description="Serve and build Jekyll sites with PlantUML support" \
      org.label-schema.docker.cmd="docker run --volume \$(pwd):/srv/jekyll ${DOCKER_IMAGE_NAME}:${TAG}" \
      org.label-schema.name="jekyll-plantuml" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.url="https://hub.docker.com/r/${DOCKER_IMAGE_NAME}" \
      org.label-schema.vcs-ref="${SHA}" \
      org.label-schema.vcs-url="https://github.com/SwedbankPay/jekyll-plantuml-docker" \
      org.label-schema.vendor="Swedbank Pay" \
      org.label-schema.version="${VERSION}"

CMD ["--help"]

ENTRYPOINT ["/var/jekyll/entrypoint/sh/entrypoint.sh"]

# How to build this Dockerfile (from the repository root directory):
#
# docker build . \
#        --file ./.docker/Dockerfile \
#        --build-arg SHA="0252c90062dd3251985a97108354d980d2de7a10" \
#        --build-arg DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
#        --build-arg VERSION="1.2.3" \
#        --build-arg TAG="1.2.3" \
#        --tag swedbankpay/jekyll-plantuml:1.2.3
#
# How to run this Dockerfile after building:
#
# docker run --volume \$(pwd):/srv/jekyll swedbankpay/jekyll-plantuml:1.2.3 [command]
#
# [command]: The optional Jekyll command to run. Defaults to 'jekyll serve'.
