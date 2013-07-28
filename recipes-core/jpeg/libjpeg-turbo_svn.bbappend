PRINC := "${@int(PRINC) + 1}"

RPROVIDES_${PN}-dev += "jpeg-dev"
RREPLACES_${PN}-dev += "jpeg-dev"
RCONFLICTS_${PN}-dev += "jpeg-dev"
