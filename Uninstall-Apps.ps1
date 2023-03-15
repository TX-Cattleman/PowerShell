<# 
       This script will detect all installed apps in Windows, display them in a gridview window, and allow you to select apps to uninstall.
    Once you select the apps you want to uninstall and click OK, the script will uninstall them one by one.
    Please note that uninstalling programs can cause data loss or system instability. 
    Always create a backup and ensure you know what each program does before proceeding with the uninstallation.
#>

# Define a function to uninstall a program using its DisplayName
function Uninstall-Program {
    param (
        [string]$DisplayName
    )
    
    $uninstallString = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | 
                       Get-ItemProperty | 
                       Where-Object {$_.DisplayName -eq $DisplayName} | 
                       Select-Object -ExpandProperty UninstallString

    if ($uninstallString) {
        Start-Process cmd -ArgumentList "/c $uninstallString /quiet /norestart" -Wait
    } else {
        Write-Host "Unable to find the uninstall string for $DisplayName."
    }
}

# Get all installed programs
$installedPrograms = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | 
                    Get-ItemProperty | 
                    Where-Object {$_.DisplayName -ne $null} | 
                    Select-Object DisplayName, Publisher, InstallDate

# Display programs in a gridview window and allow users to select programs to uninstall
$programsToUninstall = $installedPrograms | Out-GridView -Title "Select programs to uninstall" -OutputMode Multiple

# Uninstall the selected programs
if ($programsToUninstall) {
    foreach ($program in $programsToUninstall) {
        Write-Host "Uninstalling $($program.DisplayName)..."
        Uninstall-Program -DisplayName $program.DisplayName
    }
    Write-Host "Uninstallation process completed."
} else {
    Write-Host "No programs were selected for uninstallation."
}
