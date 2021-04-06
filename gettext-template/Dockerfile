FROM elementary/docker:unstable

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -yqq update && apt-get install -yqq meson git python3-git libxml2-utils appstream policykit-1 sudo

RUN groupadd -r elementary && useradd --no-log-init -r -g elementary elementary

COPY entrypoint.sh /entrypoint.sh
COPY check-diff.py /check-diff.py

ENTRYPOINT ["/entrypoint.sh"]
