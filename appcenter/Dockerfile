FROM elementary/docker:unstable

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y devscripts equivs meson git policykit-1 sudo

RUN groupadd -r elementary && useradd --no-log-init -r -g elementary elementary

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
