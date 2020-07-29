#!/bin/sh


NAME="chirp"
VALID_DONGLES="067b:2303 1a86:7523"  # Prolific Technology, Inc. PL2303 Serial Port, QinHeng Electronics HL-340 USB-Serial adapter


# Is a valid dongle attached?
for dongle in $VALID_DONGLES; do
    dev_id=$(lsusb -d $dongle | sed -n 's#Bus \([0-9]*\) Device \([0-9]*\).*#\1/\2#p')
    if [ -n "$dev_id" ]; then
        DEV_FLAG="--device=/dev/bus/usb/$dev_id:/dev/ttyUSB0"
    fi
done
if [ -z "$DEV_FLAG" ]; then
    echo "ERROR: no valid device attached" >&2
    exit 1
fi


# Already started?
if [ -n "$(docker ps -qaf "name=${NAME}")" ]; then
    echo "ERROR: ${NAME} container already started" >&2
    exit 1
fi


# Allow docker to connect to current X session
xhost +local:docker


# Build
docker build -t "local/${NAME}" $(realpath $(dirname $0))


# Run
docker run --rm -i -t \
       ${DEV_FLAG} \
       --privileged \
       --device=/dev/dri:/dev/dri \
       --volume ${HOME}/.config/gqrx:/root/.config/gqrx \
       --volume /dev/shm:/dev/shm \
       --volume /tmp/.X11-unix:/tmp/.X11-unix:ro \
       --volume /run/user/$(id -u)/pulse:/run/pulse:ro \
       --volume /var/lib/dbus:/var/lib/dbus \
       --volume /dev/snd:/dev/snd \
       --env USER_UID=$(id -u) \
       --env USER_GID=$(id -g) \
       --env DISPLAY=unix$DISPLAY \
       --name $NAME \
       local/${NAME} $@
