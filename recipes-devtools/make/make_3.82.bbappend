FILESPATH_append := ":${@base_set_filespath(['${THISDIR}/${PN}'], d)}"

SRC_URI += "file://intermediate-target-bugfix.patch"

PRINC := "${@int(PRINC) + 1}"
