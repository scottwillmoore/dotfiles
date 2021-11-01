function Hide-Dotfiles {
    Get-ChildItem -Filter ".*" | ForEach-Object { $_.Attributes = $_.Attributes -bor "Hidden" }
}

function Set-Cursor {
    param (
        [Parameter(Mandatory)]
        [ValidateSet("Block", "Underline", "Bar")]
        [String] $Style
    )

    $EscapeCharacter = "$([char] 27)"

    $CursorCode = @{
        "Block"     = 1;
        "Underline" = 3;
        "Bar"       = 5;
    }[$Style]

    Write-Host -NoNewline "$EscapeCharacter[$CursorCode q"
}

function Set-Title {
    param (
        [Parameter(Mandatory)]
        [String] $Title
    )

    $Host.UI.RawUI.WindowTitle = $Title
}

$CursorStyle = "Bar"

$PSReadLineOptions = @{
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
    EditMode            = "Vi"
    ViModeIndicator     = "Script"
    ViModeChangeHandler = {
        param (
            [Parameter(Mandatory)]
            [String] $ViMode
        )

        $CursorStyle = switch ($ViMode) {
            "Command" { "Block" }
            default { "Bar" }
        }
        
        Set-Cursor $CursorStyle
    }
}

Set-PSReadLineOption @PSReadLineOptions

if (Get-Command -ErrorAction SilentlyContinue starship) {
    Invoke-Expression (& starship init powershell)
    $StarshipPrompt = $Function:Prompt
}

function Prompt {
    if ($StarshipPrompt) {
        $EscapeCodeRegex = "($([char] 155)|$([char] 27)\[)[0-?]*[ -\/]*[@-~]"
        $Title = & starship module directory

        Set-Title ($Title -replace $EscapeCodeRegex, "")

        & $StarshipPrompt
    }
    else {
        $CurrentPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path

        $Path = Switch -wildcard ($CurrentPath) {
            "$Home" { "~" }
            "$Home\*" { $CurrentPath.Replace($Home, "~") }
            default { $CurrentPath }
        }

        Set-Title $Path

        "$Path $ "
    }
    
    if ($CursorStyle) {
        Set-Cursor $CursorStyle
    }
}
