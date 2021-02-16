# Reference to https://ocram85.com/2017-07-19-ReadOnly-Class-Properties/.
class SET {
    hidden [string]$__WT_SETUP_FILE
    hidden [string]$__POSH_THEME_PATH
    hidden [string]$__POSH_THEME_NAME
    hidden [string]$__PS_MODULE_PATH
    hidden [string]$__N2G_BACKUP_PATH
    hidden [string]$__DEFAULT_SETTING

    hidden AddPublicMember() {
        $Members = $this | Get-Member -Force -MemberType Property -Name "__*"
        foreach ($member in $Members) {
            $PublicPropertyName = $member.Name -replace "__", ""
            
            <# Define Getter part. #>
            $Getter = "return `$this.{0}" -f $member.Name
            $Getter = [ScriptBlock]::Create($Getter)
            <# Define Setter part. #>
            $Setter = "Write-Warning 'This is a READONLY property.'"
            $Setter = [ScriptBlock]::Create($Setter)

            $AddMemberParam = @{
                Name        = $PublicPropertyName
                MemberType  = "ScriptProperty"
                Value       = $Getter
                SecondValue = $Setter
            }
            $this | Add-Member @AddMemberParam 
        }
    }

    SET() {
        $this.AddPublicMember()
        $this.__WT_SETUP_FILE   = ".\basic\Microsoft.PowerShell_profile.ps1"
        $this.__POSH_THEME_PATH = [string]$([string]$(Get-Location) + "\basic\Theme")
        $this.__POSH_THEME_NAME = "QAQ"
        $this.__PS_MODULE_PATH  = [string]$([string]$(Get-Location) + "\Modules")
        $this.__N2G_BACKUP_PATH = [string]$([string]$(Get-Location) + "\backup")
        $this.__DEFAULT_SETTING = [string]$([string]$(Get-Location) + "\basic\defaultset.ps1")
    }
}