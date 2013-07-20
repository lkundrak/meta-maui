FILESPATH_append := ":${@base_set_filespath(['${THISDIR}/${PN}'], d)}"

SRC_URI += "file://glibc.git-c30e8edf7c56e55a81173da39f3e721ab17b9db6.patch"

PRINC := "${@int(PRINC) + 1}"
