# Run:
#     $ docker build -t linuxluser/chirp .
#     $ docker run -ti --rm --device=/dev/ttyUSB0:/dev/ttyUSB0 -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix linuxluser/chirp
# 

FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y software-properties-common
RUN apt-add-repository ppa:dansmith/chirp-snapshots && \
    apt-get update && \
    apt-get install -y chirp-daily && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["/usr/bin/chirpw"]
