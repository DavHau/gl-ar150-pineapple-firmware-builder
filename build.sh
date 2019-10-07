#!/usr/bin/env sh

cd openwrt-cc
make -j$((1 + $(cat /proc/cpuinfo | grep "^processor" | wc -l)))
for line in $(find "/openwrt-cc/bin" -name "*-sysupgrade.bin"); do
    ln -s $line /pineapple-firmware-sysupgrade.bin
    echo "File ready at - /pineapple-firmware-sysupgrade.bin"
done
