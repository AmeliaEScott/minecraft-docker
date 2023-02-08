FROM ubuntu:18.04
ARG javaversion=11
ENV JAVA_VERSION=$javaversion

RUN \
    apt-get update && \
    apt-get install -yq gnupg curl && \
    apt-key adv \
      --keyserver hkp://keyserver.ubuntu.com:80 \
      --recv-keys 0xB1998361219BD9C9 && \
    curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-2_all.deb && \
    apt-get install ./zulu-repo_1.0.0-2_all.deb && \
    rm zulu-repo_1.0.0-2_all.deb && \
    apt-get update && \
    apt-get install -y rdiff-backup zulu${JAVA_VERSION}-jdk python3.8 python3-pip sudo cron && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata && \
    python3.8 -m pip install mcipc requests

COPY scripts /scripts

ENV RCON_PORT=25575

ENTRYPOINT ["/scripts/entrypoint.sh"]
