OpenEmbedded/Yocto Digi Embedded Alt-Install layer
============================================

This layer provides support alternative methods for the installation of images into 
the flash of the ConnectCore 6UL (or CC6UL) family.

The meta-alt-install layer creates two new installation scripts:

**install_linux_fw_usb.scr** - This script, as its name implies, installs the DEY artifacts, 
from an USB source (e.g. flash drive) into the flash of the target.

**install_linux_fw_ram.scr** - This script is intended to be used in conjunction with NXP's MfgTool2.exe 
utility to install the artifacts from RAM into flash of the target. This script could prove 
useful for those customers looking to automate their software installation **or** have designs 
where the traditional install scripts will not work, i.e. no Ethernet connection.

SUPPORTED PLATFORMS
-------------------
  * Digi ConnectCore 6UL SBC Pro
    * [Digi P/N CC-WMX6UL-PRO](https://www.digi.com/products/models/cc-wmx6ul-kit)
  * Digi ConnectCore 6UL SBC Express
    * [Digi P/N CC-WMX6UL-START](http://www.digi.com/products/models/cc-wmx6ul-start) 

INSTALLATION
------------
1. Install the Digi Embedded Yocto (DEY) distribution
    https://github.com/digi-embedded/dey-manifest#installing-digi-embedded-yocto
2. Clone *meta-alt-install* Yocto layer under the
   Digi Embedded Yocto sources directory
        #> cd <DEY-INSTALLDIR>/sources
        #> git clone https://github.com/chaegle/meta-alt-install.git -b rocko
3. Add the meta layer to your project's bblayers.conf file.
        #> bitbake-layers add-layer <DEY-INSTALLDIR>/sources/meta-alt-install
 
USAGE
-----
 
**install_linux_fw_usb.scr**
 
 1. Boot the CC6UL device, stopping in U-Boot.
 2. At the U-Boot prompt enter the below command. Note that the value for '**usbpart**' may have to be adjusted to
    account for the device and/or partition of the USB device in use.

   => setenv install_linux_fw_usb 'usb start\;usbpart=0:0\;if fatload usb $usbpart $loadaddr install_linux_fw_usb.scr\;  then\;source $loadaddr\;else\;echo "Could not find install_linux_fw_usb.scr"\;fi\;usb stop\;'
   
   Followed by:
   
   => run install_linux_fw_usb
   
 3. The install script will update the relavent partitions and reboot.

**install_linux_fw_ram.scr**

 1. Set BOOT_MODE[0:1] to boot from Serial Downloader. On the SBC Pro and Express this is represented by the BOOT jumper on the board.
 2. Build the project, where <image-recipe-name> is core-image-base, dey-image-qt or dey-image-aws.

    e.g.
    =>bitbake <image-recipe-name>
    
 3. At this point the files *ucl2.xml* and *install_linux_fw_ram.txt* have been copied into the *tmp/deploy/images/$MACHINE* folder, but need additional manipulation. 
 4. Execute bitbake again, specifically calling for the execution of the *install_script* task. 

    e.g. 
    =>bitbake -c install_script <image-recipe-name>

 5. At this point the aforementioned ucl2.xml and install_linux_fw_usb.txt files will have been edited, having the various ##<varianble>## tags being replaced with real values.
 6. Additionally, a ZIP archive, mfgtool_installer.zip is created. This file can be unzip into the directory in which NXP's MfgTool2 utility has been installed. 

LIMITATIONS
-----------

- After the successful execution a subsequent execution of the do_install_script task will have no impact on the output artifacts, i.e. the ucl2.xml and install_linux_fw_ram.txt[scr] will not change, as the source files have already had their ##<variable>## tags replaced. The do_clean task can be called for this recipe to delete these files. 
- Currently no support for the 1GB SOM. This is to say that the outputted artifact (i.e. mfgtool_installer.zip) does not include the 1GB U-boot image.
- No support for TrustFence enabled images. In particular this meta does not support closing OR updating a close device.
- Support for the dey-image-aws image has not been tested.
