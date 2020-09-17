# Down Model$pkg "..."$pkg, posh-git, oh-my-posh
#Install-Module -Name PSReadLine -AllowPrerelease -Force
#Install-Module posh-git -Scope CurrentUser
#Install-Module oh-my-posh -Scope CurrentUser

$pkg_list = @("PSReadLine", "posh-git", "oh-my-posh")
foreach($pkg in $pkg_list) {
    If(Get-Module -ListAvailable $pkg) {
        -Join("The module ", $pkg, " exists.") | Write-Host
    } Else {
        -Join("Installing module ", $pkg, "...") | Write-Host -NoNewline
        Install-Module $pkg
        Write-Host "Finished."
    }    
}


