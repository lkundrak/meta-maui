SUMMARY = "Maui OSTree manifest and build tool"
LICENSE = "LGPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=3bf50002aefd002f49e7bb854063f7e7"

PV="2012.1"
PR="r1"

SRC_URI = "git://github.com/mauios/maui-ostree.git;tag=v${PV}"
S = "${WORKDIR}/git"

DEPENDS += "python python-argparse"

inherit autotools

FILES_${PN} += "${bindir}/ostbuild ${libdir}/ostbuild"

BBCLASSEXTEND = "native"

