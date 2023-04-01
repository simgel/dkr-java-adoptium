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
IMAGE="ghcr.io/simgel/dkr-java-adoptium:$2"
BASEI="ghcr.io/simgel/dkr-debian-base:bullseye"

( echo "${SCR_GIT_TOKEN}" | docker login -u ${GITHUB_ACTOR} --password-stdin ghcr.io ) || exit 1

( docker pull $BASEI >>build.log 2>&1 ) || exit 1


# check if update is needed

if [[ "$1" == "schedule" ]]; then
    echo ">> checking if update is needed"

    # check for apt updates
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


    # check if base image ids match
    BASEID=$(docker run --rm "$BASEI" cat /opt/dkr-image/simgel/dkr-debian-base.id)
    IMGID=$(docker run --rm "$IMAGE" cat /opt/dkr-image/simgel/dkr-debian-base.id)

    docker rmi "$IMAGE" >>build.log 2>&1

    if [[ "$ucount" == "0" && "$BASEID" == "$IMGID" ]]; then
        echo ">> no update required"
        exit 0
    else
        echo "updates found ($ucount):"
        echo "$pks"
    fi
fi

# generate new debian image

echo ">> creating new image ..."

( docker build --iidfile build.iid --build-arg "JAVA=$2" -t "$IMAGE" -f Dockerfile . >>build.log 2>&1 ) || exit 1

( docker push "$IMAGE" ) || exit 1

BIID=$(cat build.iid)

rm build.iid >>build.log 2>&1

docker rmi "$BIID" >>build.log 2>&1
