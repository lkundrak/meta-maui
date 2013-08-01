PRINC := "${@int(PRINC) + 1}"

do_install_append() {
	cmd=${D}/${bindir}/lex
	cat <<END > $cmd
#!/bin/sh
exec ${bindir}/flex -l "\$@"
END
	chmod +x $cmd
}
