Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Lambda

function ColorMatch {
<#
.DESCRIPTION
Find and highlight the pattern in string. Short for cm.
.EXAMPLE
"Hello World!" | ColorMatch "Hello" -c
.EXAMPLE
$helloWorld | cm "Hello"
#> 
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        # String to be matched. Value from pipe.
        $inputObject,
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Pattern to match.")]
        [string]
        # Pattern to match.
        $pattern,
        [Parameter(Mandatory = $false)][Switch]
        # Whether ignoring case or not(-c).
        $c
    )

    begin{ $r = [regex]$pattern }
    process {
        if ($c) { $ms = $r.Matches($inputObject) }
        else { $ms = [regex]::Matches($inputObject, $r, "IgnoreCase") }
        $startIndex = 0

        foreach($m in $ms) {
            $nonMatchLength = $m.Index - $startIndex
            Write-Host $inputObject.Substring($startIndex, $nonMatchLength) -NoNewLine
            Write-Host $m.Value -Back DarkRed -NoNewLine
            $startIndex = $m.Index + $m.Length
        }

        if($startIndex -lt $inputObject.Length) {
            Write-Host $inputObject.Substring($startIndex) -NoNewLine
        }

        Write-Host
    }
}
Set-Alias -Name cm -Value ColorMatch

function Find-String-In-Directory {
<#
.DESCRIPTION
Find files contains $string, where files under $path with names match $pattern.
Short for fsid.
.EXAMPLE
Find-String-In-Directory "Hello" *.cpp ./
.EXAMPLE
fsid "Hello" *.cpp -r -c
#> 
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Pattern to match strings.")]
        # Pattern to match strings.
        $string_pattern,
        [Parameter(Mandatory = $true, HelpMessage = "Pattern to match files.")]
        # Pattern to match files.
        $file_pattern,
        [string]
        # Find path.
        $path = "./",
        [Parameter(Mandatory = $false)][Switch]
        # Whether recursively(-r) or not.
        $r,
        [Parameter(Mandatory = $false)][Switch]
        # Whether ignoring case or not(-c).
        $c
    )

    if ($r) { $filelist = Get-ChildItem $path -recurse $file_pattern | % {$_.FullName} }
    else { $filelist = Get-ChildItem $path $file_pattern | % {$_.FullName} }
    
    Foreach ($file in $filelist) {
        $match_position = @()
        $tmpContent = Get-Content $file
        for ($i = 0; $i -lt $tmpContent.length; $i++) {
            $tmpContent[$i] = $tmpContent[$i].Trim()
            if ($c) { $isMatch = $tmpContent[$i] -cmatch $string_pattern }
            else { $isMatch = $tmpContent[$i] -match $string_pattern }
            if ($isMatch) { $match_position += $i }
        }
        if ($match_position.length -gt 0) {
            Write-Host $file
                
            Foreach ($m in $match_position) {
                Write-Host $("{0, -6}" -f $($m + 1)) -NoNewLine
                if ($c) { $tmpContent[$m] | ColorMatch $string_pattern -c }
                else { $tmpContent[$m] | ColorMatch $string_pattern } 
            }

            Write-Host
        }
    }
}
Set-Alias -Name fsid -Value Find-String-In-Directory

function Restart-Powershell {
<#
.DESCRIPTION
Restart Windows Terminal. Short for rps.
.EXAMPLE
Restart-Powershell
.EXAMPLE
rps
#>    
    $tmp = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($tmp) { Start-Process wt -Verb runas }
    else { Start-Process wt }
    
    Exit
}
Set-Alias -Name rps -Value Restart-Powershell

function Program-Check {
    param (
    )
}