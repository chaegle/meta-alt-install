#
# Insert copy right statement here
#

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI_append = " \
    file://install_linux_fw_usb.txt \
"

do_deploy_append() {
        # DEY firmware USB install script
        sed -i -e 's,##GRAPHICAL_BACKEND##,${GRAPHICAL_BACKEND},g' ${WORKDIR}/install_linux_fw_usb.txt
        mkimage -T script -n "DEY firmware install script" -C none -d ${WORKDIR}/install_linux_fw_usb.txt ${DEPLOYDIR}/install_linux_fw_usb.scr
}

