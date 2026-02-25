
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Access Denied. Right-click and run this script as Administrator."
    Pause
    Exit
}

Write-Host ">> Detaching Disk 0 from WSL..."
wsl --unmount \\.\PHYSICALDRIVE0

Write-Host ">> Bringing Disk 0 Online for Windows/BIOS..."
Set-Disk -Number 0 -IsOffline $false

Write-Host ">> SUCCESS: Arch drive is secured and ready for next boot."
Pause