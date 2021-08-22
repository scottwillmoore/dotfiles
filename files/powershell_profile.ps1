if (Get-InstalledModule -ErrorAction SilentlyContinue Posh-Git) {
    Import-Module Posh-Git
}
else {
    Write-Host "Posh-Git is not installed"
}

$CondaExe = "~\Scoop\apps\miniconda3\current\Scripts\conda.exe"

if (Test-Path $CondaExe) {
    (& $CondaExe "shell.powershell" "hook") | Out-String | Invoke-Expression
}

function Hide-Dotfiles {
    Get-ChildItem -Filter ".*" |
        ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
}

$WindowsTerminalSettings = Resolve-Path "~\AppData\Local\Packages\*WindowsTerminal*\LocalState\settings.json"

if ($WindowsTerminalSettings) {
    function Get-ValidColorSchemes {
        $IncludedColorSchemes = @(
            "Campbell",
            "Campbell Powershell",
            "Vintage",
            "One Half Dark",
            "One Half Light",
            "Solarized Dark",
            "Solarized Light",
            "Tango Dark",
            "Tango Light"
        )

        $UsedColorSchemes = Get-Content -Raw $WindowsTerminalSettings |
            ConvertFrom-Json |
            Select-Object -ExpandProperty Schemes |
            Select-Object -ExpandProperty Name

        $IncludedColorSchemes + $UsedColorSchemes |
            Sort-Object
    }

    function Get-ColorScheme {
        Get-Content $WindowsTerminalSettings -Raw |
            ConvertFrom-Json |
            Select-Object -ExpandProperty Profiles |
            Select-Object -ExpandProperty Defaults |
            Select-Object -ExpandProperty ColorScheme
    }

    function Get-Theme {
        Get-Content $WindowsTerminalSettings -Raw |
            ConvertFrom-Json |
            Select-Object -ExpandProperty Theme
    }

    function Set-ColorScheme {
        param (
            [Parameter(Mandatory)]
            [ValidateScript({
                    $_ -in $(Get-ValidColorSchemes)
                })]
            [ArgumentCompleter({
                    param ($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
                    Get-ValidColorSchemes |
                        Where-Object { $_ -like "$WordToComplete*" } |
                        ForEach-Object { "`"$_`"" }
                })]
            [String] $ColorScheme
        )

        $RawJson = Get-Content -Raw $WindowsTerminalSettings
        $RawJson = $RawJson -replace "`"colorScheme`": `".*`"", "`"colorScheme`": `"$ColorScheme`""
        Set-Content -Path $WindowsTerminalSettings -Value $RawJson
    }

    function Set-Theme {
        param (
            [Parameter(Mandatory)]
            [ValidateSet("Light", "Dark")]
            [String] $Theme
        )

        $ThemeLowercase = $Theme.ToLower()
        $RawJson = Get-Content -Raw $WindowsTerminalSettings
        $RawJson = $RawJson -replace "`"theme`": `".*`"", "`"theme`": `"$ThemeLowercase`""
        Set-Content -Path $WindowsTerminalSettings -Value $RawJson
    }

    function Toggle-ColorScheme {
        $DarkColorScheme = "Gruvbox Dark"
        $LightColorScheme = "Gruvbox Light"

        $ColorScheme = Get-ColorScheme

        if ($ColorScheme -eq $DarkColorScheme) {
            Set-ColorScheme $LightColorScheme
            Set-Theme Light
        }
        else {
            Set-ColorScheme $DarkColorScheme
            Set-Theme Dark
        }
    }
}

function Set-Title {
    param (
        [Parameter(Mandatory)]
        [String] $Title
    )

    $Host.UI.RawUI.WindowTitle = $Title
}

function Set-CursorStyle {
    param (
        [Parameter(Mandatory)]
        [ValidateSet("Block", "Underline", "Bar")]
        [String] $Style,

        [Switch] $Blink
    )

    $CursorCode = @{
        "Block"     = 2;
        "Underline" = 4;
        "Bar"       = 6;
    }[$Style]

    if ($Blink) {
        $CursorCode = $CursorCode - 1
    }

    Write-Host -NoNewline "$([char] 27)[$CursorCode q"
}

$Script:CursorStyle = "Bar"
$PSReadLineOptions = @{
    EditMode            = "Vi"
    ViModeIndicator     = "Script"
    ViModeChangeHandler = {
        param (
            [Parameter(Mandatory)]
            [String] $ViMode
        )

        $Script:CursorStyle = switch ($ViMode) {
            "Command" { "Block" }
            default { "Bar" }
        }

        Set-CursorStyle $Script:CursorStyle
    }
    Colors              = @{
        Command   = "DarkBlue"
        Comment   = "Yellow"
        Keyword   = "DarkMagenta"
        Member    = "DarkBlue"
        Number    = "Red"
        Operator  = "DarkCyan"
        Parameter = "Red"
        String    = "DarkGreen"
        Type      = "DarkYellow"
        Variable  = "DarkRed"
    }
}
Set-PSReadLineOption @PSReadLineOptions

if (Get-Command -ErrorAction SilentlyContinue starship) {
    Invoke-Expression (& starship init powershell)
    $Script:StarshipPrompt = $Function:Prompt
}

function Prompt {
    $Current = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    $Path = Switch -Wildcard ($Current) {
        "$Home" { "~" }
        "$Home\*" { $Current.Replace($Home, "~") }
        default { $Current }
    }

    if ($Script:StarshipPrompt) {
        & $Script:StarshipPrompt
    }
    else {
        "$Path $ "
    }

    if ($Script:StarshipPrompt) {
        $Regex = "($([char] 155)|$([char] 27)\[)[0-?]*[ -\/]*[@-~]"
        $Title = & starship module directory
        Set-Title ($Title -replace $Regex, "")
    }
    else {
        Set-Title $Path
    }

    if ($Script:CursorStyle) {
        Set-CursorStyle $Script:CursorStyle
    }
}

Set-Alias -Name c -Value code
Set-Alias -Name g -Value git
Set-Alias -Name l -Value ls
Set-Alias -Name n -Value nvim
Set-Alias -Name o -Value ii
Set-Alias -Name v -Value vim
