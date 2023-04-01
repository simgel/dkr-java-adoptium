FROM ghcr.io/simgel/dkr-debian-base:bullseye
ARG JAVA=17

RUN apt update -qq \
    && apt upgrade -qqy \
    && apt install -qqy wget apt-transport-https \
    && mkdir -p /etc/apt/keyrings \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public > /etc/apt/keyrings/adoptium.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb bullseye main" > /etc/apt/sources.list.d/adoptium.list \
    && apt update -qq \
    && apt install -qqy temurin-${JAVA}-jdk \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/logs/* \
    && mkdir -p chroot-bullseye/opt/dkr-image/simgel/ \
    && hexdump -n 32 -e '4/4 "%8x"' /dev/urandom > chroot-bullseye/opt/dkr-image/simgel/dkr-java-adoptium.id
