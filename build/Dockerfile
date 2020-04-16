FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y appstream-util meson valac

# create and use an elementary user instead of root
RUN groupadd -r elementary && useradd --no-log-init -r -g elementary elementary

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
