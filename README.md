
# Cross-FileSystem Transfer Scripts


I made these scripts so I can get into my encrypted 500 GB HDD and transfer files between it and Windows. If you’ve forgotten how they work again, future me, here’s the routine:

1. Open **Windows Terminal as Administrator**.
2. Run the PowerShell script from the Desktop:

   ```powershell
   & "$env:USERPROFILE\Desktop\unlock_hdd.ps1"
   ```

3. Enter the LUKS passphrase when prompted.
4. Once the script reports that the HDD is ready, open it in File Explorer:

   ```powershell
   explorer.exe "\\wsl$\Debian\mnt\wsl\hdd_arch"
   ```

That’s it. The drive is mounted inside Debian on WSL at `/mnt/wsl/hdd_arch`; Windows can reach it through `\\wsl$\Debian\mnt\wsl\hdd_arch`.

**Important:** the unlock script targets `\\.\PHYSICALDRIVE0`. On my machine, that’s the 500 GB WDC HDD. If the disks or their numbering have changed, check which physical disk is the HDD before running the script. Don’t blindly attach the wrong drive.
