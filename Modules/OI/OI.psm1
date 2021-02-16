function Build {
<#
.DESCRIPTION
Build a progrom by g++.
#>
    param (
        [string]
        # The file waiting for compiling.
        $f
    )
    g++ $($f + ".cpp") -o $f -g --std=c++11
}
Set-Alias -Name b -Value Build

function Build-Run {
<#
.DESCRIPTION
Build a progrom by g++ and run in another window.
#>
    param (
        [string]
        # The file waiting for compiling and running.
        $f
    )
    b($f)
    Start-Process $f -PassThru -NoNewWindow
}
Set-Alias -Name br -Value Build-Run

function Build-Carryout {
    param (
        [string]
        # The file waiting for compiling, running and opening.
        $f
    )
    br($f)
    cat .\sample.out
}
Set-Alias -Name bc -Value Build-Carryout

$file_template = Get-Content -Raw $($PSScriptRoot + "\template.cpp")
function New-File {
    param (
        [string]
        # The new file name.
        $f
    )
    New-Item $($f + ".cpp") -Value $file_template -Force
}
Set-Alias -Name nf -Value New-File

function Check {
    
}
Set-Alias -Name ch -Value Check