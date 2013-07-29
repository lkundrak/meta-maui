#
# Copyright (C) 2011 Colin Walters <walters@verbum.org>
# Copyright (C) 2012 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

PACKAGE_ARCH = "${MACHINE_ARCH}"
ALLOW_EMPTY_${PN} = "1"

PR = "1"

DEPENDS += " linux-maui"

RDEPENDS_${PN} += "\
	 kernel-image kernel-modules \
	 util-linux-libuuid \
	 util-linux-blkid \
	 e2fsprogs-e2fsck \
	 e2fsprogs-mke2fs \
	 e2fsprogs-tune2fs \
	 btrfs-tools \
	 libffi \
	 gdbm \
	 pciutils \
	 tiff \
	 jpeg \
	 libpng \
	 libexif \
	 libstdc++ \
	 gnutls \
	 libogg \
	 libssp \
	 eglibc-gconvs \
	 eglibc-binaries \
	 eglibc-localedatas \
	 eglibc-charmaps \
	 eglibc-locale \
	 pam-plugin-cracklib \
	 pam-plugin-env \
	 pam-plugin-keyinit \
	 pam-plugin-limits \
	 pam-plugin-localuser \
	 pam-plugin-loginuid \
	 pam-plugin-unix \
	 pam-plugin-rootok \
	 pam-plugin-succeed-if \
	 pam-plugin-permit \
	 pam-plugin-nologin \
	 ncurses-terminfo-base \
	 less \
	 nano \
	 vim-syntax vim-data vim-vimrc \
	 cpio \
	 libpcre \
	 util-linux-mount \
	 util-linux-agetty \
	 fontconfig-utils \
	 dejavu-fonts-ttf \
	 cantarell-fonts \
	 kbd \
	 kbd-consolefonts \
	 kbd-keymaps \
	 kbd-unimaps \
	 kbd \
	 gdbm \
	 tiff \
	 libogg \
	 libvorbis \
	 speex \
	 cpio \
	 libatomics-ops \
	 alsa-lib \
	 cracklib \
	 pciutils \
	 base-files \
	 base-passwd \
	 update-alternatives-cworth \
	 coreutils \
	 sed \
	 findutils \
	 strace \
	 bash \
	 tar \
	 grep \
	 gawk \
	 gzip \
	 less \
	 util-linux \
	 curl \
	 tzdata \
	 tzdata-africa \
	 tzdata-americas \
	 tzdata-antarctica \
	 tzdata-arctic \
	 tzdata-asia \
	 tzdata-atlantic \
	 tzdata-australia \
	 tzdata-europe \
	 tzdata-misc \
	 tzdata-pacific \
	 tzdata-posix \
	 tzdata-right \
	 libsndfile1 \
	 icu \
	 procps \
	 libpam \
	 attr \
	 acl \
	 libselinux \
	 policycoreutils \
	 bzip2 \
	 xz \
	 ncurses \
	 libvorbis \
	 speex \
	 nspr \
	 python-modules \
	 python-misc \
	 ruby \
	 openssh \
	 krb5 \
	 module-init-tools \
	 nss-altfiles \
	 llvm \
	 sqlite3 libsqlite3 \
	 expat \
	 rsync \
	 iputils \
	 ntfs-3g ntfsprogs \
	 syslinux-extlinux \
	 syslinux-isolinux \
	 syslinux-mbr \
	 syslinux-misc \
	 "
