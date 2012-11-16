#
# Copyright (C) 2011 Colin Walters <walters@verbum.org>
# Copyright (C) 2012 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit maui-contents

PACKAGE_INSTALL += "\
		task-maui-contents-devel \
		libltdl-dev \
		libgcc-s-dev \
		"

DEPENDS += " task-maui-contents-devel "
