param (
    [Switch] $Dry = $False,
    [Switch] $Force = $False
)

function Test-Administrator {
    $User = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $User).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Expand-Wildcard {
    param (
        [Parameter(Mandatory)]
        [String]
        $Path
    )

    $ResolvedPath = Resolve-Path $Path
    Switch -Wildcard ($ResolvedPath) {
        "$HOME\*" { "$ResolvedPath".Replace($HOME, "~") }
        default { $ResolvedPath }
    }
}

function Read-Confirmation {
    param (
        [Parameter(Mandatory)]
        [String] $Message
    )

    do {
        $Response = Read-Host $Message
        if ($Response -ilike "y*") {
            return $True
        }
        elseif ($Response -ilike "n*") {
            return $False
        }
    } until ($Response -ilike "y*" -or $Response -ilike "n*")
}

function New-DirectoryDry {
    param (
        [Parameter(Mandatory)]
        [String] $Path
    )

    if (-not $script:Dry) {
        New-Item -ItemType Directory $Path
    }
    else {
        Write-Host -NoNewline "Dry: "
    }
    Write-Host "Created directory at $Path"
}

function New-LinkDry {
    param (
        [Parameter(Mandatory)]
        [String] $Path,

        [Parameter(Mandatory)]
        [String] $Target
    )

    if (-not $script:Dry) {
        New-Item -Path $Path -ItemType SymbolicLink
    }
    else {
        Write-Host -NoNewline "Dry: "
    }
    Write-Host "Created link from $Path to $Target"
}

function New-JunctionDry {
    param (
        [Parameter(Mandatory)]
        [String] $Path,

        [Parameter(Mandatory)]
        [String] $Target
    )

    if (-not $script:Dry) {
        New-Item -Path $Path -ItemType Junction
    }
    else {
        Write-Host -NoNewline "Dry: "
    }
    Write-Host "Created junction from $Path to $Target"
}

function Copy-FileDry {
    param (
        [Parameter(Mandatory)]
        [String] $Path,

        [Parameter(Mandatory)]
        [String] $Destination
    )

    if (-not $script:Dry) {
        Copy-Item -Path $Path -Destination $Destination
    }
    else {
        Write-Host -NoNewline "Dry: "
    }
    Write-Host "Copied $Path to $Destination"
}

function Remove-FileDry {
    param (
        [Parameter(Mandatory)]
        [String] $Path
    )

    if (-not $script:Dry) {
        Remove-Item -Path $Path
    }
    else {
        Write-Host -NoNewline "Dry: "
    }
    Write-Host "Deleted file at $Path"
}

function New-Dot {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -IsValid $_ })]
        [String] $Path,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -IsValid $_ })]
        [String] $Target,

        [ValidateSet("Copy", "Junction", "Link")]
        [String] $Mode = "Link"
    )

    Write-Host

    if (Test-Path $Path) {
        Write-Host "A file at $Path already exists"

        if (-not $script:Force) {
            $Confirmation = Read-Confirmation "Do you wish to delete it"
        }

        if ($script:Force -or $Confirmation) {
            Remove-FileDry $Path
        }
        else {
            Write-Host "Skipped $Path to $Target"
            return
        }
    }

    $FromParent = Split-Path $Path
    if (-not (Test-Path $FromParent)) {
        Write-Host "A path to $Path does not exist"
        New-DirectoryDry $FromParent
    }

    switch ($Mode) {
        "Copy" { Copy-FileDry $Path $Target }
        "Junction" { New-JunctionDry $Path $Target }
        "Link" { New-LinkDry $Path $Target }
    }
}

$ScriptFile = $MyInvocation.MyCommand.Path

if (-not (Test-Administrator)) {
    $ScriptArguments = ""
    if ($Dry) { $ScriptArguments += "-Dry " }
    if ($Force) { $ScriptArguments += "-Force " }

    Write-Host "The script must be run as an administrator"
    $Confirmation = Read-Confirmation "Do you wish to elevate the script"
    if ($Confirmation) {
        Start-Process `
            -FilePath powershell `
            -Verb RunAs `
            -ArgumentList "-File `"$ScriptFile`" -Elevated $ScriptArguments" `
            -WindowStyle Maximized `
            -Wait
    }
    exit
}

Push-Location (Split-Path $ScriptFile)

New-Dot `
    -Path  "~\.bash_profile" `
    -Target "bash_profile" `

New-Dot `
    -Path  "~\.bashrc" `
    -Target "bashrc" `

New-Dot `
    -Path  "~\.gitconfig" `
    -Target "gitconfig" `

New-Dot `
    -Path "~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" `
    -Target "powershell_profile.ps1" `

New-Dot `
    -Path  "~\.config\starship" `
    -Target "gitconfig" `

New-Dot `
    -Path  "~\.tmux.conf" `
    -Target "tmux.conf" `

New-Dot `
    -Path  "~\.vimrc" `
    -Target "vimrc" `

$WindowsTerminalDirectory = "~\AppData\Local\Packages\*WindowsTerminal*"
if (Test-Path $WindowsTerminalDirectory) {
    $WindowsTerminalSettings = Expand-Wildcard "$WindowsTerminalDirectory\LocalState\settings.json"
    New-Dot `
        -Path $WindowsTerminalSettings `
        -Target "windows_terminal.json" `
        -Mode Junction
}

Pop-Location

Write-Host
Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
