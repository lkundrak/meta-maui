#
# Copyright (C) 2011 Colin Walters <walters@verbum.org>
# Copyright (C) 2012 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
#
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit rootfs_${IMAGE_PKGTYPE}

OSTREE_ROOTFS_KERNEL_VERSION = "3.8.6-maui-ostree"

do_rootfs[depends] += "linux-maui-ostree:do_deploy"

PACKAGE_INSTALL += " \
		task-maui-contents-runtime \
		ldd \
		libltdl7 \
		libicule50 \
		"

DEPENDS += "task-maui-contents-runtime makedevs-native \
	virtual/fakeroot-native \
	"

EXCLUDE_FROM_WORLD = "1"

do_rootfs[nostamp] = "1"
do_rootfs[dirs] = "${TOPDIR}"
do_rootfs[lockfiles] += "${IMAGE_ROOTFS}.lock"
do_build[nostamp] = "1"
do_rootfs[umask] = "022"

def maui_get_devtable_list(d):
    return bb.which(d.getVar('BBPATH', 1), 'files/device_table-minimal.txt')

# Must call real_do_rootfs() from inside here, rather than as a separate
# task, so that we have a single fakeroot context for the whole process.
fakeroot do_rootfs () {
        set -x

	rm -rf ${IMAGE_ROOTFS}
	rm -rf ${MULTILIB_TEMP_ROOTFS}
	mkdir -p ${IMAGE_ROOTFS}
	mkdir -p ${DEPLOY_DIR_IMAGE}

	rootfs_${IMAGE_PKGTYPE}_do_rootfs

        set -x

	# Delete all of the legacy sysvinit scripts; we use systemd
	rm -rf ${IMAGE_ROOTFS}/etc/init.d
	rm -rf ${IMAGE_ROOTFS}/etc/rc*.d

	# Empty out the default passwd file
	rm -f ${IMAGE_ROOTFS}/etc/passwd ${IMAGE_ROOTFS}/etc/group \
	  ${IMAGE_ROOTFS}/etc/shadow ${IMAGE_ROOTFS}/etc/gshadow
	# root has no password by default
	cat > ${IMAGE_ROOTFS}/etc/passwd << EOF
root::0:0:root:/root:/bin/sh
EOF
	cat > ${IMAGE_ROOTFS}/etc/group << EOF
root:x:0:root
EOF
	touch ${IMAGE_ROOTFS}/etc/shadow ${IMAGE_ROOTFS}/etc/gshadow
	chmod 0600 ${IMAGE_ROOTFS}/etc/shadow ${IMAGE_ROOTFS}/etc/gshadow
	# Delete backup files
	rm -f ${IMAGE_ROOTFS}/etc/passwd- ${IMAGE_ROOTFS}/etc/group- \
	  ${IMAGE_ROOTFS}/etc/shadow- ${IMAGE_ROOTFS}/etc/gshadow-

	# Add "altfiles" NSS module to /etc/nsswitch.conf
	sed -i -e '/^passwd:/cpasswd: files altfiles' \
	       -e '/^group:/cgroup: files altfiles' \
               ${IMAGE_ROOTFS}/etc/nsswitch.conf

	# Ensure we're set up for systemd
        echo "session optional pam_systemd.so" >> ${IMAGE_ROOTFS}/etc/pam.d/common-session 

	# Remove su because we only support pkexec
	cat > ${IMAGE_ROOTFS}/bin/su <<EOF
#!/bin/sh
exec pkexec /usr/bin/bash
EOF
	chmod u=rwx,g=rx,o=rx ${IMAGE_ROOTFS}/bin/su

	# Adjustments for /etc -> {/var,/run} here
	ln -sf /run/resolv.conf ${IMAGE_ROOTFS}/etc/resolv.conf

	# Fix un-world-readable config file; no idea why this isn't. 
	chmod a+r ${IMAGE_ROOTFS}/etc/securetty

	# Clear out the default fstab; everything we need right now is mounted
	# in the initramfs.
	cat < /dev/null > ${IMAGE_ROOTFS}/etc/fstab

	# Install defaults
	rm -f ${IMAGE_ROOTFS}/etc/localtime
	ln -s ../usr/share/zoneinfo/Europe/London ${IMAGE_ROOTFS}/etc/localtime
	echo LANG=\"en_US.UTF-8\" > ${IMAGE_ROOTFS}/etc/locale.conf

	# Do the kernel and modules
	mkdir -p ${IMAGE_ROOTFS}/boot
	cp -p ${DEPLOY_DIR_IMAGE}/bzImage-${OSTREE_ROOTFS_KERNEL_VERSION} ${IMAGE_ROOTFS}/boot/vmlinuz-${OSTREE_ROOTFS_KERNEL_VERSION}
	echo "Extracting modules.tgz"
	tar -x -C "${IMAGE_ROOTFS}" -z -f ${DEPLOY_DIR_IMAGE}/modules-${OSTREE_ROOTFS_KERNEL_VERSION}.tgz

	# Remove all .la files
	find ${IMAGE_ROOTFS}/lib -name \*.la -delete
	find ${IMAGE_ROOTFS}/usr/lib -name \*.la -delete

	# Undo libattr/libacl weirdness
	rm -f ${IMAGE_ROOTFS}/lib/lib{acl,attr}.a
	rm -f ${IMAGE_ROOTFS}/usr/lib/lib{acl,attr}.so

	# Do UsrMove for bin and sbin
	mv ${IMAGE_ROOTFS}/bin/* ${IMAGE_ROOTFS}/usr/bin
	if test -d ${IMAGE_ROOTFS}/bin/.debug; then
	  mkdir -p ${IMAGE_ROOTFS}/usr/bin/.debug
	  mv ${IMAGE_ROOTFS}/bin/.debug/* ${IMAGE_ROOTFS}/usr/bin/.debug
	  rmdir ${IMAGE_ROOTFS}/bin/.debug
	fi
	rmdir ${IMAGE_ROOTFS}/bin
	ln -s usr/bin ${IMAGE_ROOTFS}/bin
	mv ${IMAGE_ROOTFS}/sbin/* ${IMAGE_ROOTFS}/usr/sbin
	if test -d ${IMAGE_ROOTFS}/sbin/.debug; then
	  mkdir -p ${IMAGE_ROOTFS}/usr/sbin/.debug
	  mv ${IMAGE_ROOTFS}/sbin/.debug/* ${IMAGE_ROOTFS}/usr/sbin/.debug
	  rmdir ${IMAGE_ROOTFS}/sbin/.debug
	fi
	rmdir ${IMAGE_ROOTFS}/sbin
	ln -s usr/sbin ${IMAGE_ROOTFS}/sbin
	# Now, we need to fix up any symbolic links that were
	# trying to do ../usr/
	for d in ${IMAGE_ROOTFS}/usr/bin ${IMAGE_ROOTFS}/usr/sbin; do
	    find $d -maxdepth 1 -type l | while read f; do
	        target=$(readlink $f)
	        fixed_target=$(echo $target | sed -e 's,^[.][.]/usr,,')
		ln -sf $fixed_target $f
	    done
	done

	# Complete UsrMove for lib
	mv ${IMAGE_ROOTFS}/lib/* ${IMAGE_ROOTFS}/usr/lib
	if test -d ${IMAGE_ROOTFS}/lib/.debug; then
	  mkdir -p ${IMAGE_ROOTFS}/usr/lib/.debug
	  mv ${IMAGE_ROOTFS}/lib/.debug/* ${IMAGE_ROOTFS}/usr/lib/.debug
	  rmdir ${IMAGE_ROOTFS}/lib/.debug
	fi
	rmdir ${IMAGE_ROOTFS}/lib
	ln -s usr/lib ${IMAGE_ROOTFS}/lib

	# And now let's take the next logical step, merge /usr/sbin
	# into /usr/bin.  Rusty Russell will be overjoyed:
	# http://rusty.ozlabs.org/?p=236
	if test -d ${IMAGE_ROOTFS}/usr/sbin/.debug; then
		mkdir -p ${IMAGE_ROOTFS}/usr/bin/.debug
		mv ${IMAGE_ROOTFS}/usr/sbin/.debug/* ${IMAGE_ROOTFS}/usr/bin/.debug
		rmdir ${IMAGE_ROOTFS}/usr/sbin/.debug
	fi
	for x in ${IMAGE_ROOTFS}/usr/sbin/*; do
		mv ${x} ${IMAGE_ROOTFS}/usr/bin
	done
	rmdir ${IMAGE_ROOTFS}/usr/sbin
	ln -s bin ${IMAGE_ROOTFS}/usr/sbin

	# And ensure systemd is /sbin/init
	ln -s ../lib/systemd/systemd ${IMAGE_ROOTFS}/usr/sbin/init

	TOPROOT_BIND_MOUNTS="home root tmp"
	OSTREE_BIND_MOUNTS="var"
	OSDIRS="dev proc mnt media run sys sysroot"
	READONLY_BIND_MOUNTS="boot bin etc lib sbin usr"
	
	rm -rf ${WORKDIR}/maui-contents
	mkdir ${WORKDIR}/maui-contents
        cd ${WORKDIR}/maui-contents
	for d in $TOPROOT_BIND_MOUNTS $OSTREE_BIND_MOUNTS $OSDIRS; do
	    mkdir $d
	done

	ln -s sysroot/ostree ostree

	for d in $READONLY_BIND_MOUNTS; do
            mv ${IMAGE_ROOTFS}/$d .
	done
	rm -rf ${IMAGE_ROOTFS}
	mv ${WORKDIR}/maui-contents ${IMAGE_ROOTFS}

	# Ok, let's globally fix permissions; everything is root owned,
	# all directories are u=rwx,og=rx, except for /root, and /tmp is sticky
	chown -R -h 0:0 ${IMAGE_ROOTFS}
	find ${IMAGE_ROOTFS} -type d -exec chmod u=rwx,og=rx "{}" \;
	chmod a=rwxt ${IMAGE_ROOTFS}/tmp
	chmod go-rwx ${IMAGE_ROOTFS}/root

	IMAGE_NAME_NODATE=${IMAGE_BASENAME}-${MACHINE}.tar.gz
	DEST=${WORKDIR}/${IMAGE_NAME_NODATE}
	(cd ${IMAGE_ROOTFS} && tar -zcv -f ${DEST} .)

	mv ${DEST} ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME_NODATE}
}

log_check() {
	true
}

do_fetch[noexec] = "1"
do_unpack[noexec] = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_install[noexec] = "1"
do_populate_sysroot[noexec] = "1"
do_package[noexec] = "1"
do_package_write_ipk[noexec] = "1"
do_package_write_deb[noexec] = "1"
do_package_write_rpm[noexec] = "1"

addtask rootfs before do_build

# stub out for now
rootfs_install_all_locales () {
    true
}

rootfs_install_complementary () {
    true
}
