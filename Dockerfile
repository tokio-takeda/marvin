FROM node:0-wheezy

MAINTAINER tokio-takeda<takeda@genuine-pt.jp>

# Usual update / upgrade
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && \
        apt-get install -y git-core

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install coffee-script, hubot
RUN npm install -g npm
RUN npm install -g hubot coffee-script
RUN npm install -g request

# Working enviroment
ENV BOTDIR /opt/bot
RUN install -o nobody -d ${BOTDIR}
ENV HOME ${BOTDIR}
WORKDIR ${BOTDIR}

USER nobody

# Install slack adapter
RUN npm install hubot-slack --save

RUN cd ${BOTDIR} && git clone https://github.com/tokio-takeda/marvin.git

# Entrypoint
ENTRYPOINT ["/bin/sh", "-c", "cd ${BOTDIR}/marvin && bin/hubot --adapter slack"]
