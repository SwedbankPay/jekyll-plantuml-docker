FROM ruby:2.7.1

ENV BUNDLE_HOME="/usr/local/bundle" \
    BUNDLE_APP_CONFIG="$BUNDLE_HOME" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    GEM_HOME="/usr/gem" \
    GEM_PATH="$GEM_HOME" \
    GEM_BIN="$GEM_HOME/bin" \
    JEKYLL_BIN="/usr/jekyll/bin" \
    JEKYLL_DATA_DIR="/srv/jekyll" \
    JEKYLL_ENV="development" \
    JEKYLL_VAR_DIR="/var/jekyll" \
    JEKYLL_VERSION="4.0.1" \
    GIT_DEPLOY_DIR="${JEKYLL_DATA_DIR}/_site" \
    DRAFTS=false \
    FORCE_POLLING=false \
    VERBOSE=false

ENV PATH="${JEKYLL_BIN}:${GEM_BIN}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Create all folders needed by RubyGems, Bundler, etc.
RUN addgroup --system --gid 1000 jekyll && \
    adduser --system --gid 1000 jekyll && \
    mkdir -p $JEKYLL_VAR_DIR && \
    mkdir -p $JEKYLL_DATA_DIR && \
    mkdir -p $JEKYLL_BIN

RUN apt-get clean && \
    apt-get update && \
    apt-get \
    --no-install-recommends \
    install -y \
    locales=2.28-10 \
    default-jre=2:1.11-71 \
    graphviz=2.40.1-6 \
    fontconfig=2.13.1-2 && \
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
RUN gem install jekyll \
    --install-dir $JEKYLL_VAR_DIR \
    --bindir $JEKYLL_BIN \
    --version $JEKYLL_VERSION \
    -- --use-system-libraries

COPY --chown=jekyll:jekyll .docker/jekyll-plantuml/Gemfile ${JEKYLL_VAR_DIR}/
COPY --chown=jekyll:jekyll .docker/jekyll-plantuml/Gemfile.lock ${JEKYLL_VAR_DIR}/
COPY --chown=jekyll:jekyll .docker/jekyll-plantuml/_config.yml ${JEKYLL_VAR_DIR}/_config.yml

RUN bundle config build --use-system-libraries && \
    bundle install --gemfile=${JEKYLL_VAR_DIR}/Gemfile

# Clean up cache folders, as they aren't needed in a Docker container.
RUN rm -rf /root/.gem && \
    rm -rf /home/jekyll/.gem && \
    rm -rf $BUNDLE_HOME/cache && \
    rm -rf $GEM_HOME/cache

# Make sure jekyll:jekyll owns everything.
RUN chown -R jekyll:jekyll $JEKYLL_DATA_DIR && \
    chown -R jekyll:jekyll $JEKYLL_VAR_DIR && \
    chown -R jekyll:jekyll $JEKYLL_BIN && \
    chown -R jekyll:jekyll $BUNDLE_HOME

COPY --chown=jekyll:jekyll .docker/entrypoint ${JEKYLL_BIN}/entrypoint
ADD --chown=jekyll:jekyll \
    https://github.com/SwedbankPay/git-directory-deploy/raw/1.0.4/deploy.sh \
    ${JEKYLL_BIN}/deploy.sh
RUN chmod +x ${JEKYLL_BIN}/deploy.sh

VOLUME  /srv/jekyll
WORKDIR /srv/jekyll

EXPOSE 35729
EXPOSE 4000

CMD ["jekyll", "serve", "--livereload", "--incremental", "--force_polling", "--watch", "--host", "0.0.0.0"]

ENTRYPOINT ["/usr/jekyll/bin/entrypoint"]
