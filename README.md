OpenEmbedded/Yocto Digi Embedded Alt-Install layer
============================================

This layer provides support alternative methods for the installation of images into 
the flash of the ConnectCore 6UL. 

The meta-alt-install layer creates a new script, install_linux_fw_usb.scr. 
This script, as its name indicates, installs the necessary DEY project artifacts 
into the NAND flash of the target CC6UL device.  

Supported Platforms
-------------------
  * Digi ConnectCore 6UL SBC Pro
    * [Digi P/N CC-WMX6UL-PRO](https://www.digi.com/products/models/cc-wmx6ul-kit)
  * Digi ConnectCore 6UL SBC Express
    * [Digi P/N CC-WMX6UL-START](http://www.digi.com/products/models/cc-wmx6ul-start) 


Installation
------------
1. Install Digi Embedded Yocto distribution

    https://github.com/digi-embedded/dey-manifest#installing-digi-embedded-yocto

2. Clone *meta-alt-install* Yocto layer under the
   Digi Embedded Yocto sources directory

        #> cd <DEY-INSTALLDIR>/sources
        #> git clone https://github.com/chaegle/meta-alt-install.git -b rocko

3. Add the meta layer to your project's bblayers.conf file.

        #> bitbake-layers add-layer <DEY-INSTALLDIR>/sources/meta-alt-install

 Usage
 -----
 1. Boot the CC6UL device, stopping in U-Boot.
 2. At the U-Boot prompt enter the below command. Note that the value for 'usbpart' may have to be adjusted to
    account for the device and/or partition of the USB device in use.
   
   => setenv install_linux_fw_usb "usb start\;usbpart=0:0\;if fatload usb $usbpart $loadaddr install_linux_fw_usb.scr\; 
   then\;source $loadaddr\;else\;echo "Could not find install_linux_fw_usb.scr"\;fi\;usb stop\;"
   
   Followed by:
   
   => run install_linux_fw_usb
 
 3. The install script will update the relavent partitions and reboot.
