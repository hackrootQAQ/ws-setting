# Update profile.
Copy-Item "./Microsoft.PowerShell_profile.ps1" $PROFILE
if ($args[0] -eq "-p") {exit}

# Install package.
$pkg_list = @("PSReadLine", "posh-git", "oh-my-posh")
foreach($pkg in $pkg_list) {
    If(Get-Module -ListAvailable $pkg) {
        -Join("The module ", $pkg, " exists.") | Write-Host
    } Else {
        -Join("Installing module ", $pkg, "...") | Write-Host -NoNewline
        Install-Module $pkg -Force
        Write-Host "Finished."
    }    
}

# Get setting path.
$prefix = -Join("C:\Users\", $env:USERNAME, "\AppData\Local\Packages\")
$suffix = "\LocalState\"
$setting_loc = Dir $prefix | ? {$_ -is [System.IO.DirectoryInfo] -and $_.Name -like "Microsoft.WindowsTerminal_*"} `
    | Foreach-Object {$_.Name}
$setting_loc = -Join($prefix, $setting_loc, $suffix)

# Get map from name to guid.
$setting_file_loc = -Join($setting_loc, "settings.json")
$CONFIG = Get-Content $setting_file_loc | ConvertFrom-Json
$name2guid = @{}
For ($i = 0; $i -lt $CONFIG.profiles.list.Count; $i = $i + 1) { 
    $_ = $CONFIG.profiles.list[$i]
    $name2guid[$_.name] = @($_.guid, $i)
}

# Backup.
$ID = $env:USERDOMAIN
$ID_path = -Join("./backup/", $ID, "/")
$null = New-Item -Path "./backup" -Name $ID -Type Directory -Force 
Copy-Item $setting_file_loc $(-Join($ID_path, $(Get-Date -Format "MM_dd_yyyy_HH_mm_ss"), "settings.json"))
$name2guid | ConvertTo-Json | Out-File $(-Join($ID_path, "name2guid.json")) 

function change {
    param (
        $need_change,
        $change_file
    )
    $tmp_c = Get-Content $change_file | ConvertFrom-Json -AsHashtable
    #echo $($need_change | Get-Member -MemberType Method)
    #echo $($need_change | Get-Member -MemberType Properties)
    $name_list = $need_change.psobject.Properties.name
    foreach ($name in $tmp_c.keys) {
        if ($name -in $name_list) {
            $need_change.$name = $tmp_c[$name]
        } else {
            $need_change | Add-Member -MemberType NoteProperty -Name $name -Value $tmp_c[$name]
        }
    }
    return $need_change
}
function add {
    param (
        $need_change,
        $change_file 
    )
    $tmp_c = Get-Content $change_file | ConvertFrom-Json -AsHashtable
    $need_change += $tmp_c
    return $need_change
}

# Change setting.
$need_change = $CONFIG.profiles.list[$name2guid["PowerShell"][1]]
$change_file = "./changed/c1.json"
$CONFIG.profiles.list[$name2guid["PowerShell"][1]] = change $need_change $change_file
$change_file = "./changed/c2.json"
$CONFIG.schemes += @{}
$CONFIG.schemes = add $CONFIG.schemes $change_file

# Update.
if ($CONFIG[0] -eq $null) {
    $CONFIG[1] | ConvertTo-Json -Depth 100 | Out-File $(-Join($ID_path, "settings_new.json")) 
} else {
    $CONFIG[0] | ConvertTo-Json -Depth 100 | Out-File $(-Join($ID_path, "settings_new.json"))     
}
Copy-Item $(-Join($ID_path, "settings_new.json")) $setting_file_loc