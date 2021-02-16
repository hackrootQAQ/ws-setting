@(
    @{
        Type  = "CHANGE"
        Name  = '.profiles.list[$name2guid["PowerShell"][1]]'
        Value = '
            {
                "hidden": false,
                "commandline": "C:/Program Files/PowerShell/7/pwsh.exe -nologo",
                "source": "Windows.Terminal.PowershellCore",
                "startingDirectory": ".",
                "fontFace": "Fira Code",
                "fontSize": 11,
                "historySize": 9001,
                "padding": "5, 5, 20, 25",
                "snapOnInput": true,
                "useAcrylic": false,
                "colorScheme": "Homebrew"
            }
        '
    }, 
    @{
        Type  = "CHANGE"
        Name  = '.profiles.list[$name2guid["Ubuntu-18.04"][1]]'
        Value = '
            {
                "hidden": false,
                "source": "Windows.Terminal.Wsl",
                "startingDirectory": ".",
                "fontFace": "Fira Code",
                "fontSize": 11,
                "historySize": 9001,
                "padding": "5, 5, 20, 25",
                "snapOnInput": true,
                "useAcrylic": false,
                "colorScheme": "Homebrew"
            }
        '
    },
    @{
        Type  = "ADD"
        Name  = '.schemes'
        Value = '
            {
                "name": "Homebrew",
                "black": "#000000",
                "red": "#FC5275",
                "green": "#00a600",
                "yellow": "#999900",
                "blue": "#6666e9",
                "purple": "#b200b2",
                "cyan": "#00a6b2",
                "white": "#bfbfbf",
                "brightBlack": "#666666",
                "brightRed": "#e50000",
                "brightGreen": "#00d900",
                "brightYellow": "#e5e500",
                "brightBlue": "#0000ff",
                "brightPurple": "#e500e5",
                "brightCyan": "#00e5e5",
                "brightWhite": "#e5e5e5",
                "background": "#283033",
                "foreground": "#00ff00"
            }
        '
    }
)