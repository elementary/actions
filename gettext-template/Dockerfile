ARG ELEMENTARY_CODENAME=unstable
FROM elementary/docker:${ELEMENTARY_CODENAME}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && apt-get install -qq meson git python3-git libxml2-utils appstream policykit-1 sudo translate-toolkit

RUN groupadd -r elementary && useradd --no-log-init -r -g elementary elementary

COPY entrypoint.sh check-diff.py update-appstream-percentages.py /

ENTRYPOINT ["/entrypoint.sh"]
