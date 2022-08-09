# syntax=docker/dockerfile:1
# perl version as argument BASE
# ARG BASE
# FROM perl:${BASE}
FROM perl:5.36

WORKDIR /build/
COPY cpanfile /tmp/

RUN apt-get update && \
        apt-get dist-upgrade -y && \
        apt-get -y --no-install-recommends install aspell aspell-en && \
        apt-get -y --no-install-recommends install git

RUN cpanm -nq App::cpm Carton::Snapshot
RUN cpm install -g --show-build-log-on-failure --cpanfile /tmp/cpanfile

RUN cpan-outdated --exclude-core -p | xargs -n1 cpanm

CMD ["/bin/bash"]
