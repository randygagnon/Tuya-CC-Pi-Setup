# Tuya-CC-Pi-Setup

## A shell script to automatically set up a raspberry pi for Tuya Cloud Cutter
Inspired by 
[https://github.com/tuya-cloudcutter/tuya-cloudcutter/blob/main/HOST_SPECIFIC_INSTRUCTIONS.md](https://github.com/tuya-cloudcutter/tuya-cloudcutter/blob/main/HOST_SPECIFIC_INSTRUCTIONS.md)

Steps:

1. Use Raspberry Pi Imager to burn "Raspberry Pi OS Lite (32 Bit)" to an SD card
    1. As of this note, 2022-04-04 build of Bullseye
    2. A 4GB SD card is required to have enough space for the OS and building the Docker image.
    3. If using SSH, enable it (using the installer or making an empty file ssh on the boot partition)
2. Access the pi (SSH or keyboard + monitor)
3. Pull down the shell script and run it
   
   ***IMPORTANT!*** _It is good security hygiene to ***ALWAYS*** review scripts prior to running them so you know what they're doing._
   
   ```shell
   wget -O - https://raw.githubusercontent.com/<username>/<project>/<branch>/<path>/<file> | bash
   ```
   If there were errors, please open a Github Issue in this repo
5. If everything worked, reboot when the script asks and then continue with the regular instructions like
   ```bash
   cd ~/tuya-cloudcutter/
   sudo ./tuya-cloudcutter.sh -r
   ```
