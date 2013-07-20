FILESPATH_append := ":${@base_set_filespath(['${THISDIR}/${PN}'], d)}"

SRC_URI += "file://0001-loginuid-Add-no-overwrite-option.patch"

PRINC := "${@int(PRINC) + 1}"
