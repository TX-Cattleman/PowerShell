# This script is to move the MicroSIP application from DefaultUser0\AppData\Local\MicroSIP
# to the current user's same path.

# Get the current username
$currentUsername = $env:USERNAME

# Add current user to local Administrators group
$adminGroup = [ADSI]"WinNT://./Administrators,group"
$currentUser = [ADSI]"WinNT://./$currentUsername,user"
$adminGroup.Add($currentUser.Path)

Write-Host "Current user added to the local Administrators group"

# Grant Administrators full access to DefaultUser0's AppData\Local directory
$aclPath = "C:\Users\DefaultUser0\AppData\Local"
$acl = Get-Acl -Path $aclPath
$administrators = [System.Security.Principal.NTAccount]::new("Administrators")
$accessRule = [System.Security.AccessControl.FileSystemAccessRule]::new($administrators, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($accessRule)

# Change the owner to Administrators
$administratorsIdentity = $administrators.Translate([System.Security.Principal.SecurityIdentifier])
$acl.SetOwner($administratorsIdentity)

# Enable inheritance and include child objects
$acl.SetAccessRuleProtection($false)
$acl.SetAccessRuleProtection($true, $true)

Set-Acl -Path $aclPath -AclObject $acl

Write-Host "Administrators granted full access to $aclPath"
Write-Host "Owner of $aclPath changed to Administrators"

# Set the source and destination paths
$sourcePath = "C:\Users\DefaultUser0\AppData\Local\MicroSIP"
$destinationPath = "C:\Users\$currentUsername\AppData\Local"

# Copy the source directory to the destination
Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force
Write-Host "Copied directory: $sourcePath to $destinationPath"

# Run the microsip.exe application
$microsipPath = Join-Path $destinationPath "MicroSIP\microsip.exe"
Start-Process -FilePath $microsipPath

# Create a shortcut on the user's desktop
$shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "MicroSIP.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $microsipPath
$shortcut.Save()

Write-Host "MicroSIP application started. Shortcut created on desktop: $shortcutPath"
