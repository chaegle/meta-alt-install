#
# Insert appropriate license statement here
#

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS += " extra-install-files"

do_install_script() {

   # task variables
   LOADADDR=2147483648 # 0x80000000
   SCRIPT_OFFSET=4096  # 0x1000

   LINUX_FILENAME=${BPN}-${GRAPHICAL_BACKEND}-${MACHINE}.boot.ubifs
   RECOVERY_FILENAME=${BPN}-${GRAPHICAL_BACKEND}-${MACHINE}.recovery.ubifs
   ROOTFS_FILENAME=${BPN}-${GRAPHICAL_BACKEND}-${MACHINE}.ubifs

   UBOOT_LOADADDR=`expr $LOADADDR + $SCRIPT_OFFSET`
   UBOOT_FILESIZE=$(wc -c < ${DEPLOY_DIR_IMAGE}/u-boot-${MACHINE}.imx)

   LINUX_LOADADDR=`expr $UBOOT_LOADADDR + $UBOOT_FILESIZE`
   LINUX_FILESIZE=$(wc -c < ${DEPLOY_DIR_IMAGE}/$LINUX_FILENAME)

   RECOVERY_LOADADDR=`expr $LINUX_LOADADDR + $LINUX_FILESIZE`
   RECOVERY_FILESIZE=$(wc -c < ${DEPLOY_DIR_IMAGE}/$RECOVERY_FILENAME)

   ROOTFS_LOADADDR=`expr $RECOVERY_LOADADDR + $RECOVERY_FILESIZE`
   ROOTFS_FILESIZE=$(wc -c < ${DEPLOY_DIR_IMAGE}/$ROOTFS_FILENAME)

   # Custom install script
   sed -i -e "s,##LOADADDR##,$(printf "0x%x" $LOADADDR),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt
   
   sed -i -e "s,##UBOOT_LOADADDR##,$(printf "0x%x" $UBOOT_LOADADDR),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt
   sed -i -e "s,##UBOOT_FILESIZE##,$(printf "0x%x" $UBOOT_FILESIZE),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt
   
   sed -i -e "s,##LINUX_LOADADDR##,$(printf "0x%x" $LINUX_LOADADDR),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt
   sed -i -e "s,##LINUX_FILESIZE##,$(printf "0x%x" $LINUX_FILESIZE),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt
   
   sed -i -e "s,##RECOVERY_LOADADDR##,$(printf "0x%x" $RECOVERY_LOADADDR),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt
   sed -i -e "s,##RECOVERY_FILESIZE##,$(printf "0x%x" $RECOVERY_FILESIZE),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt
   
   sed -i -e "s,##ROOTFS_LOADADDR##,$(printf "0x%x" $ROOTFS_LOADADDR),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt
   sed -i -e "s,##ROOTFS_FILESIZE##,$(printf "0x%x" $ROOTFS_FILESIZE),g" ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt

# Modify NXP MfgTool2 ucl2.xml file

   sed -i -e "s,##MACHINE##,${MACHINE},g" ${DEPLOY_DIR_IMAGE}/ucl2.xml
   sed -i -e "s,##LINUX_FILENAME##,"$LINUX_FILENAME",g" ${DEPLOY_DIR_IMAGE}/ucl2.xml
   sed -i -e "s,##RECOVERY_FILENAME##,"$RECOVERY_FILENAME",g" ${DEPLOY_DIR_IMAGE}/ucl2.xml
   sed -i -e "s,##ROOTFS_FILENAME##,"$ROOTFS_FILENAME",g" ${DEPLOY_DIR_IMAGE}/ucl2.xml
   sed -i -e "s,##BPN##,${BPN},g" ${DEPLOY_DIR_IMAGE}/ucl2.xml

   sed -i -e "s,##SCRIPT_LOADADDR##,$(printf "0x%x" $LOADADDR),g" ${DEPLOY_DIR_IMAGE}/ucl2.xml
   sed -i -e "s,##UBOOT_LOADADDR##,$(printf "0x%x" $UBOOT_LOADADDR),g" ${DEPLOY_DIR_IMAGE}/ucl2.xml
   sed -i -e "s,##LINUX_LOADADDR##,$(printf "0x%x" $LINUX_LOADADDR),g" ${DEPLOY_DIR_IMAGE}/ucl2.xml
   sed -i -e "s,##RECOVERY_LOADADDR##,$(printf "0x%x" $RECOVERY_LOADADDR),g" ${DEPLOY_DIR_IMAGE}/ucl2.xml
   sed -i -e "s,##ROOTFS_LOADADDR##,$(printf "0x%x" $ROOTFS_LOADADDR),g" ${DEPLOY_DIR_IMAGE}/ucl2.xml

   mkimage -T script -n "RAM Install Script" -C none -d ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.txt ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.scr

   install -d ${DEPLOY_DIR_IMAGE}/mfgtool_dir
   install -m 0644 ${DEPLOY_DIR_IMAGE}/mfgtool_dir
}

addtask install_script after do_image_complete
