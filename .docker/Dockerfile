FROM ruby:2.7.1

ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG=/usr/local/bundle \
    BUNDLE_HOME=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    GEM_BIN=/usr/gem/bin \
    GEM_HOME=/usr/gem \
    JEKYLL_VAR_DIR=/var/jekyll \
    JEKYLL_VERSION=4.0.1 \
    JEKYLL_DATA_DIR=/srv/jekyll \
    JEKYLL_BIN=/usr/jekyll/bin \
    JEKYLL_ENV=development \
    PATH="$JEKYLL_BIN:$BUNDLE_BIN:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    VERBOSE=false \
    FORCE_POLLING=false \
    DRAFTS=false \
    GIT_DEPLOY_DIR="${JEKYLL_DATA_DIR}/_site"

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

RUN unset GEM_HOME \
    && unset GEM_BIN \
    && yes | gem update --system
RUN unset GEM_HOME \
    && unset GEM_BIN \
    && yes | gem install --force bundler
RUN gem install jekyll --version $JEKYLL_VERSION -- --use-system-libraries
RUN gem install \
    html-proofer \
    jekyll-reload \
    jekyll-mentions \
    jekyll-coffeescript \
    jekyll-sass-converter \
    jekyll-commonmark \
    jekyll-paginate \
    jekyll-compose \
    jekyll-assets \
    jekyll-github-metadata \
    jekyll-material-icon-tag \
    RedCloth \
    kramdown \
    jemoji \
    jekyll-redirect-from \
    jekyll-sitemap \
    jekyll-feed minima \
    nokogiri \
    kramdown-plantuml \
    faraday \
    minitest \
    activesupport \
    public_suffix \
    fastimage \
    hike \
    rb \
    rexml \
    rouge \
    mini_magick \
    multi_json \
    rack \
    tilt \
    sprockets \
    sprockets \
    sprockets \
    jekyll \
    -- --use-system-libraries

RUN addgroup --system --gid 1000 jekyll && \
    adduser --system --gid 1000 jekyll && \
    mkdir -p $JEKYLL_VAR_DIR && \
    mkdir -p $JEKYLL_DATA_DIR && \
    chown -R jekyll:jekyll $JEKYLL_DATA_DIR && \
    chown -R jekyll:jekyll $JEKYLL_VAR_DIR && \
    chown -R jekyll:jekyll $BUNDLE_HOME && \
    rm -rf /root/.gem && \
    rm -rf /home/jekyll/.gem && \
    rm -rf $BUNDLE_HOME/cache && \
    rm -rf $GEM_HOME/cache

COPY --chown=jekyll:jekyll .docker/entrypoint ${JEKYLL_BIN}/entrypoint
ADD --chown=jekyll:jekyll \
    https://github.com/SwedbankPay/git-directory-deploy/raw/1.0.4/deploy.sh \
    ${JEKYLL_BIN}/deploy.sh
RUN chmod +x ${JEKYLL_BIN}/deploy.sh

VOLUME  /srv/jekyll
WORKDIR /srv/jekyll

EXPOSE 35729
EXPOSE 4000

CMD ["jekyll", "serve", "--livereload", "-i", "--force_polling", "--watch", "--host", "0.0.0.0"]

ENTRYPOINT ["/usr/jekyll/bin/entrypoint"]
