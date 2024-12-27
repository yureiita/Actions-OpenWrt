#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

#luci-theme-argon and luci-app-argon-config
# cd package
# git clone https://github.com/jerrykuku/luci-theme-argon.git
# git clone https://github.com/jerrykuku/luci-app-argon-config.git

# patch for libfring which causes build to fail https://github.com/openwrt/packages/issues/23621
if [[ "$REPO_BRANCH" == "v23.05.3" ]]; then
    [ -e "$GITHUB_WORKSPACE"/patches/999-issue-23621.patch ] && mkdir -p feeds/packages/libs/libpfring/patches/ && cp "$GITHUB_WORKSPACE"/patches/999-issue-23621.patch "$_"
fi

# copy Archer C6 V2 BDF
if [[ "$CONFIG_FILE" =~ ^"archer-c6-v2" ]]; then
    [ -e "$GITHUB_WORKSPACE"/archer-c6-v2-files/board-2.bin ] && mkdir -p files/lib/firmware/ath10k/QCA9888/hw2.0/ && cp "$GITHUB_WORKSPACE"/archer-c6-v2-files/board-2.bin "$_"
fi

if [[ $REPO_BRANCH =~ ^"v" ]]; then
    sed -i "s/SNAPSHOT/${REPO_BRANCH/"v"}/" .config
    sed -i '/CONFIG_VERSION_CODE_FILENAMES=y/d' .config
elif [[ $REPO_BRANCH =~ ^"openwrt-" ]]; then
    sed -i "s/\(SNAPSHOT\)/${REPO_BRANCH/"openwrt-"}-\1/" .config
fi
