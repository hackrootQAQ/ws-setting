$P_NOTE_PATH = $($env:NOTE_PATH + "\paper\")
function New-Note {
    param (
        [string]
        # The note dir name.
        $d,
        [string]
        # The paper title.
        $t = $d
    )
    New-Item $($P_NOTE_PATH + $d) -Type Directory -Force
    New-Item $($P_NOTE_PATH + $d + "\README.md") -Type File -Value $("## " + $t) -Force
    ii $($P_NOTE_PATH + $d)
    Out-File -FilePath $($P_NOTE_PATH + "abbr") -InputObject $($t + " = " + $d) -Append -Force
}
Set-Alias -Name nn -Value New-Note

function Get-Endnote {
    param (
        [string]
        # File to parser.
        $f
    )
    $con = Get-Content $f
    $ret = New-Object PSObject
    foreach ($line in $con) {
        $label = $line.Substring(0, 2)
        $value = $line.Substring(3)
        if ($label -eq "%D") { $ret | Add-Member -Type NoteProperty -Name Date -Value $value }
        if (($label -eq "%J") -or ($label -eq "%B")) { $ret | Add-Member -Type NoteProperty -Name Jour -Value $value }
        if ($label -eq "%A") {
            if (-not $ret.Auth) { $ret | Add-Member -Type NoteProperty -Name Auth -Value @() }
            $ret.Auth += $value
        }
    }
    Return $ret
}

function Get-Info {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [System.IO.FileSystemInfo]
        # Note directory.
        $d
    )
    $ret = New-Object PSObject
    $ret | Add-Member -Type NoteProperty -Name Abbr -Value $d.Name
    $ret | Add-Member -Type NoteProperty -Name CrTm -Value $d.CreationTime
    $ret | Add-Member -Type NoteProperty -Name AcTm -Value $d.LastAccessTime
    $ret | Add-Member -Type NoteProperty -Name WrTm -Value $d.LastWriteTime
    if (Test-Path $($d.FullName + "\scholar.enw")) {
        $tmp = Get-Endnote $($d.FullName + "\scholar.enw")
        $ret | Add-Member -Type NoteProperty -Name EdNt -Value $tmp 
    }
    Return $ret
}

function Write-List {
    param (
        [Parameter(Mandatory = $false)][switch]
        # For detail(-d) or not.
        $d
    )
    $m = Get-Content $($P_NOTE_PATH + "abbr") -Raw | ConvertFrom-StringData
    if ($d) {
        $info = @{} 
        Get-ChildItem $P_NOTE_PATH | % { $info.Add($_.Name, $(Get-Info $_)) }
        foreach ($_ in $m.Keys) {
            Write-Host $_
            $tmp = $info[$m[$_]]
            Write-Host $("  * Abbr : " + $tmp.Abbr)
            <# CreationTime #>
            Write-Host $("  * CrTm : " + $tmp.CrTm)
            <# LastAccessTime #>
            Write-Host $("  * AcTm : " + $tmp.AcTm)
            <# LastWriteTime #>
            Write-Host $("  * WrTm : " + $tmp.WrTm)
            if ($tmp.EdNt) {
                <# Date #>
                Write-Host $("  * Date : " + $tmp.EdNt.Date)
                <# Author #>
                Write-Host $("  * Auth : " + $($tmp.EdNt.Auth -Join "; "))
                <# Journal #>
                Write-Host $("  * Jour : " + $tmp.EdNt.Jour)
            }
            Write-Host
        }
    } else {
        $m | Format-Table -AutoSize
    }
}
Set-Alias -Name wl -Value Write-List

function Find-Note {
    param (
        [string]
        # The paper title.
        $t
    )
    
}
Set-Alias -Name fn -Value Find-Note