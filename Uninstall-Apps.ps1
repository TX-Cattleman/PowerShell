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
