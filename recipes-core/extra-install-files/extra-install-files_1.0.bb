# Copyright (C) 2019 Digi International.

DESCRIPTION = "Additional files to update images via ramdisk"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

inherit deploy

SRC_URI = " \
    file://install_linux_fw_ram.txt \
    file://ucl2.xml \
    file://run_mfgtool.bat \
"

do_install () {
    install -m 0644 ${WORKDIR}/install_linux_fw_ram.txt ${DEPLOY_DIR_IMAGE}/
    install -m 0644 ${WORKDIR}/ucl2.xml ${DEPLOY_DIR_IMAGE}/
    install -m 0644 ${WORKDIR}/run_mfgtool.bat ${DEPLOY_DIR_IMAGE}/
}
