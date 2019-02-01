FROM nginx:1.9.12

ARG EMBER_ENV=development

RUN apt-get update \
	&& apt-get install -y curl git bzip2 libfontconfig1-dev xz-utils

RUN set -ex \
	&& for key in \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        77984A986EBC2AA786BC0F66B01FBB92821C587A \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
	; do \
        gpg --keyserver pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
        gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
	done

ENV NPM_CONFIG_LOGLEVEL info

ENV NODE_VERSION 10.8.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

RUN \
	npm install -g ember-cli@3.6.1

ADD package.json /tmp/client/

RUN cd /tmp/client && npm install 
ADD . /tmp/client
RUN cd /tmp/client && ember build --environment=${EMBER_ENV} && mv dist/* /usr/share/nginx/html/ && rm -rf /tmp/client
ADD nginx.conf /etc/nginx/conf.d/default.conf

CMD /bin/bash -c "nginx -g 'daemon off;'"