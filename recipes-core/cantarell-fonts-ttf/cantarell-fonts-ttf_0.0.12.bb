SUMMARY = "Cantarell font family"
DESCRIPTION = "The Cantarell typeface family is a contemporary Humanist \
sans serif, and is used by the GNOME project for its user \
interface and the Fedora project."
SECTION = "x11/fonts"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=9f867da7a73fad2715291348e80d0763"
PR = "r2"
RDEPENDS_${PN} = "fontconfig-utils"

inherit allarch

SRC_URI = "http://download.gnome.org/sources/cantarell-fonts/0.0/cantarell-fonts-${PV}.tar.xz"

do_configure() {
        oe_runconf
}

pkg_postinst_${PN} () {
#!/bin/sh
fc-cache
}


FILES_${PN} = "/etc ${datadir}/fonts"

SRC_URI[md5sum] = "6011af6f0a0a5ebdd1e35691ab346401"
SRC_URI[sha256sum] = "3d509e1117dd92a6b80ef8b2586c89e178dc21a03c7c61f5c50772def5c4934b"
