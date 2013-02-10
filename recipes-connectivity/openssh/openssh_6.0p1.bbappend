FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI += "file://sshdgenkeys.service file://sshd.service file://sshd@.service file://sshd.socket"

PRINC := "${@int(PRINC) + 1}"

do_install_append () {
	install -d ${D}${libdir}/systemd/system
	for file in sshdgenkeys.service sshd.service sshd@.service sshd.socket; do
		install -m 0644 ${WORKDIR}/${file} ${D}${libdir}/systemd/system
	done
}

FILES_${PN}-sshd += "${libdir}/systemd/system/sshd.service"
FILES_${PN}-sshd += "${libdir}/systemd/system/sshd@.service"
FILES_${PN}-sshd += "${libdir}/systemd/system/sshd.socket"
FILES_${PN}-keygen += "${libdir}/systemd/system/sshdgenkeys.service"
