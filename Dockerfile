FROM engineyard/kontainers:ruby-2.5-v1.0.0

# An example of installing commonly-used packages
RUN apt-get update && apt-get install -y imagemagick libsqlite3-dev

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app
WORKDIR /app

ARG RAILS_ENV
# Copy the main application.
COPY . ./

# Install dependencies
RUN ./.eyk/bundler_install.sh
RUN bundle install --jobs 20 --retry 5

# Create the needed config files on docker build time
# For these to work, make sure you configure build args
# for your app with the following before pushing:
# eyk config:set DEIS_DOCKER_BUILD_ARGS_ENABLED=1
ARG db_yml_database
ARG db_yml_username
ARG db_yml_password
ARG db_yml_host

# Replace selected raw config with equivalents designed for use with
# your cluster. You can edit the source files as necessary. Particularly,
# you might want to change the environment specified in these files.
RUN erb -T - ./.eyk/config/database.yml.erb > config/database.yml
RUN erb -T - ./.eyk/config/sidekiq.yml.erb > config/sidekiq.yml

# Make the migration script runable
RUN chmod +x ./.eyk/migrations/db-migrate.sh

# Precompile Rails assets
RUN bundle exec rake assets:precompile

# Expose port 5000 to the Docker host, so we can access it
# from the outside. This is the same as the one set with
# "eyk config:set PORT 5000"
EXPOSE 5000

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD sleep 3600