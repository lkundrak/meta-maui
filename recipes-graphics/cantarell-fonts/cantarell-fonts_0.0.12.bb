SUMMARY = "Cantarell font family"
DESCRIPTION = "The Cantarell typeface family is a contemporary Humanist \
sans serif, and is used by the GNOME project for its user \
interface and the Fedora project."
SECTION = "x11/fonts"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=0fa7ab31d2f5d9fc9b8b272f79a061c2"
PR = "r0"
RDEPENDS_${PN} = "fontconfig-utils"

inherit allarch

SRC_URI = "http://download.gnome.org/sources/${PN}/0.0/${PN}-${PV}.tar.xz \
           file://21-cantarell-hinting.conf"

do_configure() {
	./configure --prefix=${prefix} --with-fontdir=${datadir}/fonts/truetype --with-configdir=${sysconfdir}/fonts/conf.d --disable-source-rebuild
}

do_compile() {
	make
}

do_install() {
	oe_runmake DESTDIR=${D} install

	install -d ${D}${sysconfdir}/fonts/conf.d/
	install -m 0644 ${WORKDIR}/21-cantarell-hinting.conf ${D}${sysconfdir}/fonts/conf.d/
}

pkg_postinst_${PN} () {
#!/bin/sh
fc-cache
}

PACKAGES = "${PN}"
FILES_${PN} += "${sysconfdir} ${datadir}"

SRC_URI[md5sum] = "6011af6f0a0a5ebdd1e35691ab346401"
SRC_URI[sha256sum] = "3d509e1117dd92a6b80ef8b2586c89e178dc21a03c7c61f5c50772def5c4934b"
