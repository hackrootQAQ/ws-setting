# Load basic setting.
using module ".\CONSTANT.psm1"
$CustomSetting = New-Object SET
# Set whether to show debug information or not.
if ("-d" -in $args) { $DebugPreference = "Continue" }

# Update profile.
Copy-Item $CustomSetting.WT_SETUP_FILE $PROFILE
<# Add .\Modules to $env:PSModulePath. #>
$AddOrder = "`$env:PSModulePath += " + """;" + $CustomSetting.PS_MODULE_PATH + """`n"
$AddOrder + $(Get-Content $PROFILE -Raw) | Set-Content $PROFILE
<# Add .\base\Themes to posh theme location. #>
$AddOrder = "`$ThemeSettings.MyThemesLocation = """ + $CustomSetting.POSH_THEME_PATH + """`n"
$(Get-Content $PROFILE -Raw) + $AddOrder | Set-Content $PROFILE
<# Change setting name. #>
$AddOrder = "Set-Theme " + $CustomSetting.POSH_THEME_NAME + "`n"
$(Get-Content $PROFILE -Raw) + $AddOrder | Set-Content $PROFILE
Write-Debug "WT setting updated."
if ("-u" -in $args) { exit }

# Install package.
$PkgList = @("PSReadLine", "posh-git", "oh-my-posh")
foreach($pkg in $PkgList) {
    if (Get-Module -ListAvailable $pkg) {
        -Join("The module ", $pkg, " exists.") | Write-Debug
    } else {
        -Join("Installing module ", $pkg, "...") | Write-Debug -NoNewline
        Install-Module $pkg -Force
    }
}

# Get setting path.
$prefix = -Join("C:\Users\", $env:USERNAME, "\AppData\Local\Packages\")
$suffix = "\LocalState\"
$SettingLocation = Dir $prefix | ? {$_ -is [System.IO.DirectoryInfo] -and $_.Name -like "Microsoft.WindowsTerminal_*"} `
    | Foreach-Object {$_.Name}
$SettingLocation = -Join($prefix, $SettingLocation, $suffix)
Write-Debug "WT setting path got."

# Get map from name to guid.
$SettingFileLocation = -Join($SettingLocation, "settings.json")
try { $CONFIG = Get-Content $SettingFileLocation -Raw | ConvertFrom-Json }
catch { 
    Write-Debug "Can't parse the original setting, try reinstall WT please." 
    exit
}
$name2guid = @{}
for ($i = 0; $i -lt $CONFIG.profiles.list.Count; $i = $i + 1) { 
    $_ = $CONFIG.profiles.list[$i]
    $name2guid[$_.Name] = @($_.guid, $i)
}

# Backup. `-nb` Set whether to backup or not.
if ("-nb" -in $args) { Write-Debug "No backup." }
else {
    $COMID = $env:USERDOMAIN
    $BackupPath = "{0}\{1}\" -f $CustomSetting.N2G_BACKUP_PATH, $COMID
    if (-not $(Test-Path $BackupPath)) {
        <# Hidden the output of command `New-Item`. #>
        $null = New-Item -Path $BackupPath -Type Directory -Force 
    }
    Copy-Item $SettingFileLocation $($BackupPath + $(Get-Date -Format "MM_dd_yyyy_HH_mm_ss") + "settings.json")
    $name2guid | ConvertTo-Json | Out-File $($BackupPath + "name2guid.json") 
    Write-Debug "Backuped."
}

function change($origin, $new) {
    $content = $new | ConvertFrom-Json -AsHashtable
    $NameList = $origin.PSobject.Properties.Name
    $ret = New-Object PSObject
    foreach ($name in ($content.Keys + $NameList)) {
        if ($name -in $content.Keys) { 
            $ret | Add-Member -MemberType NoteProperty -Name $name -Value $content[$name] -Force
        } else { $ret | Add-Member -MemberType NoteProperty -Name $name -Value $origin.$name -Force }
    }
    return $ret
}
function add($origin, $new) {
    $ret = $origin + $($new | ConvertFrom-Json -AsHashtable)
    return $ret
}

# Read wt default setting -> Change setting -> Update.
$WTDefaultSetting = $(iex $(Get-Content $CustomSetting.DEFAULT_SETTING -Raw))
foreach ($wtds in $WTDefaultSetting) {
    $ConfigVarName = "`$CONFIG" + $wtds.Name        
    try {
        if ($wtds.Type -eq "CHANGE") {
            iex $("{0} = change {0} {1}" -f $ConfigVarName, "`$wtds.Value") 
        } elseif ($wtds.Type -eq "ADD") {
            if ($null -eq $(iex $ConfigVarName)) {  iex $("{0} += @{{}}" -f $ConfigVarName) }        
            iex $("{0} = add {0} {1}" -f $ConfigVarName, "`$wtds.Value")
        } else { Write-Debug "Undefined operator."; exit }
    } catch {
        Write-Debug "Some wrong in WT default setting file, please check it."
        exit
    }
}
if ($null -eq $CONFIG[0]) {
    $CONFIG[1] | ConvertTo-Json -Depth 100 | Out-File $($BackupPath + "settings_new.json") 
} else {
    $CONFIG[0] | ConvertTo-Json -Depth 100 | Out-File $($BackupPath + "settings_new.json")     
}
Copy-Item $($BackupPath + "settings_new.json") $SettingFileLocation
Write-Debug "WT setting updated."