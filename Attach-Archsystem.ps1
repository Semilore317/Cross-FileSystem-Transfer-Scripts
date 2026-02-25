if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Access Denied. Right-click and run this script as Administrator."
    Pause
    Exit
}

Write-Host ">> Taking Physical Disk 0 Offline..."
Set-Disk -Number 0 -IsOffline $true

Write-Host ">> Attaching Disk 0 to WSL..."
wsl --mount \\.\PHYSICALDRIVE0 --bare

Write-Host ">> SUCCESS: The drive is now passed to WSL."
Write-Host ">> Next Step: Run 'sudo ./cold_storage.sh /mnt/c/path/to/game' in your Debian terminal."
Pause