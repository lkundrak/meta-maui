DEPENDS = "cracklib-native zlib"
DEPENDS_class-native = "zlib"

PRINC := "${@int(PRINC) + 1}"

BBCLASSEXTEND = "native"

do_install_append_class-target() {
	create-cracklib-dict -o ${D}${datadir}/cracklib/pw_dict ${D}${datadir}/cracklib/cracklib-small
}

do_install_append_virtclass-native() {
}
