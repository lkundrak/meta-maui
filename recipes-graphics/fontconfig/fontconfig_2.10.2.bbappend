PRINC := "${@int(PRINC) + 1}"

EXTRA_OECONF += " --with-cache-dir=/usr/lib/fontconfig/cache"
