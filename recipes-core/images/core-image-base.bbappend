#
# Insert appropriate license statement here
#

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS += " extra-install-files zip-native"

INSTALLER_SCRIPT_FOLDER = "mfgtool_installer"

#
# Generate ZIP Archive, containing all files necessary for use 
# with NXP's MfgTool2 utility
#
generate_mfgtool_installer_zip() {

   # create mfgtool folder structure
   install -d "${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}/Profiles/${MACHINE}-ram-install/OS Firmware/${MACHINE}"
   # copy files
   install -m 0644 ${DEPLOY_DIR_IMAGE}/ucl2.xml "${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}/Profiles/${MACHINE}-ram-install/OS Firmware"
   install -m 0644 ${DEPLOY_DIR_IMAGE}/install_linux_fw_ram.scr "${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}/Profiles/${MACHINE}-ram-install/OS Firmware/${MACHINE}"
   install -m 0644 ${DEPLOY_DIR_IMAGE}/run_mfgtool.bat "${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}"

   # Symlinks of DEY artifacts
   # Make sure symlinks exist
   if readlink -e ${DEPLOY_DIR_IMAGE}/$UBOOT_FILENAME > /dev/null; then 
           ln -s ${DEPLOY_DIR_IMAGE}/$UBOOT_FILENAME "${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}/Profiles/${MACHINE}-ram-install/OS Firmware/${MACHINE}/$UBOOT_FILENAME"
   else
           # TODO: Abort with error message
           bberror "File, ${DEPLOY_DIR_IMAGE}/$UBOOT_FILENAME NOT found."
   fi

   if readlink -e ${DEPLOY_DIR_IMAGE}/$LINUX_FILENAME > /dev/null; then
           ln -s ${DEPLOY_DIR_IMAGE}/$LINUX_FILENAME "${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}/Profiles/${MACHINE}-ram-install/OS Firmware/${MACHINE}/$LINUX_FILENAME"
   else
           # TODO: Abort with error message
           bberror "File, ${DEPLOY_DIR_IMAGE}/$LINUX_FILENAME NOT found"
   fi

   if readlink -e ${DEPLOY_DIR_IMAGE}/$RECOVERY_FILENAME > /dev/null; then
           ln -s ${DEPLOY_DIR_IMAGE}/$RECOVERY_FILENAME "${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}/Profiles/${MACHINE}-ram-install/OS Firmware/${MACHINE}/$RECOVERY_FILENAME"
   else
           # TODO: Abort with error message
           bberror "File, ${DEPLOY_DIR_IMAGE}/$RECOVERY_FILENAME NOT found"
   fi

   if readlink -e ${DEPLOY_DIR_IMAGE}/$ROOTFS_FILENAME > /dev/null; then
           ln -s ${DEPLOY_DIR_IMAGE}/$ROOTFS_FILENAME "${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}/Profiles/${MACHINE}-ram-install/OS Firmware/${MACHINE}/$ROOTFS_FILENAME"
   else
           # TODO: Abort with error message
           bberror "File, ${DEPLOY_DIR_IMAGE}/$ROOTFS_FILENAME NOT found"
   fi


# TODO: Zip up mfgtool_installer_dir folder (sans base folder)
 
   cd ${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}
   zip -r ${INSTALLER_SCRIPT_FOLDER}.zip *
   mv ${INSTALLER_SCRIPT_FOLDER}.zip ${DEPLOY_DIR_IMAGE}
}


do_install_script() {

   # task variables
   LOADADDR=2147483648 # 0x80000000
   SCRIPT_OFFSET=4096  # 0x1000

   UBOOT_FILENAME=u-boot-${MACHINE}.imx
   LINUX_FILENAME=${BPN}-${MACHINE}.boot.ubifs
   RECOVERY_FILENAME=${BPN}-${MACHINE}.recovery.ubifs
   ROOTFS_FILENAME=${BPN}-${MACHINE}.ubifs

   UBOOT_LOADADDR=`expr $LOADADDR + $SCRIPT_OFFSET`
   UBOOT_FILESIZE=$(wc -c < ${DEPLOY_DIR_IMAGE}/$UBOOT_FILENAME)

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

generate_mfgtool_installer_zip;

}

addtask install_script after do_image_complete

do_clean_script() {

  # TODO: Add check for existence of file before trying to delete
  FILE="${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}"
  if test -d "$FILE"; then  
          `rm -Rf ${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}` 
  fi

  # TODO: Add check for existence of file before trying to delete
  FILE="${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}.zip"
  if test -f "$FILE"; then  
          `rm ${DEPLOY_DIR_IMAGE}/${INSTALLER_SCRIPT_FOLDER}.zip` 
  fi
}

addtask clean_script before install_script
 
