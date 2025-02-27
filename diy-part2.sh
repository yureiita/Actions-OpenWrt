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
    # [ -e "$GITHUB_WORKSPACE"/archer-c6-v2-files/board-2.bin ] && mkdir -p files/lib/firmware/ath10k/QCA9888/hw2.0/ && cp "$GITHUB_WORKSPACE"/archer-c6-v2-files/board-2.bin "$_"
    sed -i '/tplink_eap660hd-v1 \\/a \\ttplink_archer-c6-v2 \\' package/firmware/ipq-wifi/Makefile
    sed -i '/TP-Link EAP660 HD v1/a $(eval $(call generate-ipq-wifi-package,tplink_archer-c6-v2,TP-Link Archer C6 V2))' package/firmware/ipq-wifi/Makefile
    sed -i 's/TARGET_ipq40xx/TARGET_ath79||TARGET_ipq40xx/' package/firmware/ipq-wifi/Makefile
    sed -i 's|$$$$(wildcard $(PKG_BUILD_DIR)/board-$(1).*)|$$$$(wildcard $(PKG_BUILD_DIR)/board-$(1).*) $$$$(wildcard files/board-$(1).*)|' package/firmware/ipq-wifi/Makefile
    cat package/firmware/ipq-wifi/Makefile
    [ -e "$GITHUB_WORKSPACE"/archer-c6-v2-files/board-tplink_archer-c6-v2.qca9888 ] && mkdir -p package/firmware/ipq-wifi/files/ && cp "$GITHUB_WORKSPACE"/archer-c6-v2-files/board-tplink_archer-c6-v2.qca9888 "$_"
    ls -l package/firmware/ipq-wifi/files/
    sed -i '/nvmem-cell-names = "pre-calibration", "mac-address";/a \\t\tqcom,ath10k-calibration-variant = "tplink_archer-c6-v2";' target/linux/ath79/dts/qca9563_tplink_archer-c6-v2.dts
    cat target/linux/ath79/dts/qca9563_tplink_archer-c6-v2.dts
    sed -i '/ARCHER-C6-V2$/{n;s/$/ -ath10k-board-qca9888 ipq-wifi-tplink_archer-c6-v2/}' target/linux/ath79/image/generic-tp-link.mk
    cat target/linux/ath79/image/generic-tp-link.mk
fi

if [[ $REPO_BRANCH =~ ^"v" ]]; then
    sed -i "s/SNAPSHOT/${REPO_BRANCH/"v"}/" .config
    sed -i '/CONFIG_VERSION_CODE_FILENAMES=y/d' .config
elif [[ $REPO_BRANCH =~ ^"openwrt-" ]]; then
    sed -i "s/\(SNAPSHOT\)/${REPO_BRANCH/"openwrt-"}-\1/" .config
fi

if [[ "$REPO_BRANCH" == *"24.10"* ]]; then
    sed -i '/CONFIG_PACKAGE_px5g-mbedtls=y/i CONFIG_PACKAGE_owut=y' .config
    echo "RELEASE_PACKAGE=${RELEASE_PACKAGE/usteer/usteer, owut}" >> "$GITHUB_ENV"
fi
