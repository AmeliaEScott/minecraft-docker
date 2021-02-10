FROM ubuntu:18.04

RUN \
    apt-get update && \
    apt-get install -y rdiff-backup openjdk-11-jdk python3.8 python3-pip sudo && \
    python3.8 -m pip install mcipc requests

COPY scripts /scripts

ENV RCON_PORT=25575

ENTRYPOINT ["/scripts/entrypoint.sh"]