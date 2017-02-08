FROM ubuntu:16.04
MAINTAINER Jamison Dance <jamison@yours.co>

RUN mkdir -p /home/meteor

# Install git, curl, node
RUN apt-get update && \
	apt-get install -y git curl build-essential && \
	(curl https://deb.nodesource.com/setup_4.x | bash) && \
	apt-get install -y \
    nodejs \
    jq

WORKDIR /home/meteor

## Install entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /usr/bin/entrypoint.sh

# Allow these to be overridden by children
ONBUILD ENV ROOT_URL http://127.0.0.1
ONBUILD ENV NODE_TLS_REJECT_UNAUTHORIZED 0

ONBUILD ARG METEOR_APP_PATH=.
ONBUILD ADD ${METEOR_APP_PATH} /home/meteor/src
ONBUILD ARG GIT_HASH
ONBUILD LABEL git-commit=$GIT_HASH

ONBUILD RUN /usr/bin/entrypoint.sh

# we use the exec form of ENTRYPOINT so our our node process is running as pid 1
# `docker stop` sends SIGTERM to pid 1. This means we can gracefully handle
# containers being stopped
# NOTE: It looks like we are leaving some zombie processes when running as PID 1
# Switch back to this when zombie processes are figured out
#ENTRYPOINT ["node", "--max-old-space-size=2048", "/home/meteor/www/bundle/main.js"]
ENTRYPOINT node --max-old-space-size=2048 /home/meteor/www/bundle/main.js
