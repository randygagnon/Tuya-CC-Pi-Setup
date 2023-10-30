# Tuya-CC-Pi-Setup

## A shell script to automatically set up a raspberry pi for Tuya Cloud Cutter

Inspired by:

[https://github.com/tuya-cloudcutter/tuya-cloudcutter/blob/main/HOST_SPECIFIC_INSTRUCTIONS.md](https://github.com/tuya-cloudcutter/tuya-cloudcutter/blob/main/HOST_SPECIFIC_INSTRUCTIONS.md)

Steps:

1. Use Raspberry Pi Imager to burn "Raspberry Pi OS Lite (32 Bit)" to an SD card
    1. The official doc states compatibility with 2022-04-04 build of Bullseye, but I was able to use latest Raspberry Pi OS Lite (32 bit) 2023-10-10 on a Pi 4b 1gb
    2. A 4GB SD card is required to have enough space for the OS and building the Docker image.
    3. If using SSH, enable it (using the Pi Imager app or making an empty file ssh on the boot partition)
2. SSH into the freshly imaged Pi and then Pull down this automated setup shell script and run it

   _**IMPORTANT!** It is good security hygiene to **ALWAYS** review scripts prior to running them so you know what they're doing.\
   If your countrycode is something other than US, simply add it onto the end when you run the script. Example: "./setup.sh GB" or "./setup.sh CA"_

   ```shell
   wget https://raw.githubusercontent.com/randygagnon/Tuya-CC-Pi-Setup/main/setup.sh && chmod +x setup.sh
   less setup.sh # Use less command to view the script. Press up/down arrow keys to review the code before pressing q to quit
   ./setup.sh
   ```

   If there were errors, please open a Github Issue in this repo
3. If everything worked, type y to reboot then continue with the [regular instructions](https://github.com/tuya-cloudcutter/tuya-cloudcutter/blob/main/INSTRUCTIONS.md):

   ```bash
   cd ~/tuya-cloudcutter/
   sudo ./tuya-cloudcutter.sh -r
   ```
