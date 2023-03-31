#!/bin/bash

cleanup() {
    rv=$?

    if [[ -f "build.cid" ]]; then
        BCID=$(cat build.cid)
        docker rm "$BCID"
        rm -f build.cid
    fi

    if [[ -f "build.iid" ]]; then
        BIID=$(cat build.iid)
        docker rmi "$BIID"
        rm -f build.iid
    fi

    if [[ "$rv" == "1" && -f "build.log" ]]; then
        tail build.log -n 50
    fi

    rm -f build.log

    exit $rv
}

trap cleanup EXIT

# BUILD --------------
echo "build for java version $2"

( echo "${SCR_GIT_TOKEN}" | docker login -u ${GITHUB_ACTOR} --password-stdin ghcr.io ) || exit 1

IMAGE="ghcr.io/simgel/dkr-java-adoptium:$2"


# check if update is needed

if [[ "$1" == "schedule" ]]; then
    echo ">> checking if update is needed"

    RNDTAG=$(hexdump -n 16 -e '4/4 "%08x"' /dev/urandom)
    
    ( docker pull "$IMAGE" >>build.log 2>&1 ) || exit 1

    ( docker build --iidfile build.iid --build-arg "TAG=$2" -t "$RNDTAG" -f Dockerfile.check . >>build.log 2>&1 ) || exit 1

    pks=$(docker run --cidfile build.cid -i "$RNDTAG" >>build.log 2>&1) || exit 1
    ucount=$(echo -n "$pks" | wc -l)

    BIID=$(cat build.iid)
    BCID=$(cat build.cid)

    rm build.iid build.cid >>build.log 2>&1

    docker rm "$BCID" >>build.log 2>&1
    docker rmi "$BIID" >>build.log 2>&1
    docker rmi "$IMAGE" >>build.log 2>&1

    if [[ "$ucount" == "0" ]]; then
        echo ">> no update required"
        exit 0
    else
        echo "updates found ($ucount):"
        echo "$pks"
    fi
fi

# generate new debian image

echo ">> creating new image ..."

( docker pull ghcr.io/simgel/dkr-debian-base:bullseye >>build.log 2>&1 ) || exit 1

( docker build --iidfile build.iid --build-arg "JAVA=$2" -t "$IMAGE" -f Dockerfile . >>build.log 2>&1 ) || exit 1

( docker push "$IMAGE" ) || exit 1

BIID=$(cat build.iid)

rm build.iid >>build.log 2>&1

docker rmi "$BIID" >>build.log 2>&1
