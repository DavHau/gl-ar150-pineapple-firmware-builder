FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo wget curl python \
    git build-essential zlib1g-dev liblzma-dev python-magic subversion \
    build-essential git-core libncurses5-dev zlib1g-dev gawk flex quilt \
    libssl-dev xsltproc libxml-parser-perl mercurial bzr ecj cvs unzip
# checkout modules
RUN git clone https://github.com/devttys0/binwalk &&\
    git clone https://github.com/mirror/firmware-mod-kit &&\
    git clone https://github.com/domino-team/openwrt-cc

RUN wget https://www.wifipineapple.com/downloads/nano/latest -O upgrade.bin

# install binwalk
RUN cd binwalk && ./deps.sh --yes
RUN cd binwalk && python setup.py install
RUN echo "BINWALK=binwalk" >> firmware-mod-kit/shared-ng.inc

RUN mkdir firmware_images

# extract firmware
RUN cd firmware-mod-kit &&\
    ./extract-firmware.sh /upgrade.bin
RUN mkdir openwrt-cc/files &&\
    cp -r firmware-mod-kit/fmk/rootfs/* openwrt-cc/files/ &&\
    rm -rf openwrt-cc/files/lib/modules/* &&\
    rm -rf openwrt-cc/files/sbin/modprobe

# openwrt feeds
RUN cd openwrt-cc &&\
    ./scripts/feeds update -a &&\
    ./scripts/feeds install -a

# build firmware
COPY configs/gl-mifi-defconfig openwrt-cc/.config
RUN cd openwrt-cc && make defconfig

copy build.sh /build.sh
