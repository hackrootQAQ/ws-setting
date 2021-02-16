# How to Set Windows Terminal

This project is wrote for setting a more practical Windows Terminal.

### Environment needed

* Font: Fira Code
* Kernal: Powershell 7 or later
* Package: PSReadLine, posh-git, oh-my-posh

The needed packages will be checked whether installed or not in `run.ps1`. If not installed, please use the following commands `set-executionpolicy remotesigned` to get the authority for running the script, which will install them automatically.

### How to use

Get update of your settings of Windows Terminal and powershell by `run.ps1`. 
Add context menu items by `install.ps1` and remove it running `uninstall.ps1`, which is referenced to https://github.com/lextm/windowsterminal-shell/.

Additional instructions for `run.ps1`:
* Switch to the directory where the script is to run is necessary.
* Use switch `-u` to only update the powershell startup setting, namely `Microsoft.PowerShell_profile.ps1`.
* Use switch `-d` to show the debug information.
* Use switch `-nb` to not backup the original configuration.

### How to customize

There are two parts can be customized, one is the *WT's native configuration*, another one is about the *plug-in oh-my-posh*.

* ***WT's native configuration***: Reference to file `\basic\default.ps1`.
* ***plug-in oh-my-posh***: Reference to file `\basic\Theme\QAQ.psm1`.

All of these two parts can be modified by yourself. You can change the setting file lacation in `CONSTANT.psm1`, which defines some read-only variables corresponding to customized information in class `SET`. Notice your new variable name should begin with `__`, but drop it while using.