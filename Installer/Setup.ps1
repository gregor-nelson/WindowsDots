#Requires -Version 5.1
<#
.SYNOPSIS
    Windows development environment setup script.
.DESCRIPTION
    Installs required programs (Windows Terminal, Neovim, PowerShell Core) via winget
    and creates symlinks for configuration files from this dotfiles repository.
.NOTES
    Must be run as Administrator for symlink creation.
#>

[CmdletBinding()]
param(
    [switch]$SkipInstall,
    [switch]$SkipSymlinks,
    [switch]$Force
)

# ============================================================================
# Configuration
# ============================================================================

$Script:DotfilesRoot = Split-Path -Parent $PSScriptRoot

$Script:Programs = @(
    @{
        Name        = "Windows Terminal"
        WingetId    = "Microsoft.WindowsTerminal"
        CheckType   = "Appx"
        AppxName    = "Microsoft.WindowsTerminal"
    },
    @{
        Name        = "Neovim"
        WingetId    = "Neovim.Neovim"
        CheckType   = "Command"
        Command     = "nvim"
    },
    @{
        Name        = "PowerShell Core"
        WingetId    = "Microsoft.PowerShell"
        CheckType   = "Command"
        Command     = "pwsh"
    }
)

$Script:Symlinks = @(
    @{
        Name        = "Neovim Config"
        Source      = Join-Path $DotfilesRoot "Vim"
        Target      = Join-Path $env:LOCALAPPDATA "nvim"
        Type        = "Directory"
    },
    @{
        Name        = "Windows Terminal Settings"
        Source      = Join-Path $DotfilesRoot "Terminal\settings.json"
        Target      = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        Type        = "File"
    },
    @{
        Name        = "PowerShell Profile"
        Source      = Join-Path $DotfilesRoot "Powershell\Microsoft.PowerShell_profile.ps1"
        Target      = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Microsoft.PowerShell_profile.ps1"
        Type        = "File"
    }
)

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )

    $colors = @{
        Info    = "Cyan"
        Success = "Green"
        Warning = "Yellow"
        Error   = "Red"
    }

    $prefixes = @{
        Info    = "[*]"
        Success = "[+]"
        Warning = "[!]"
        Error   = "[-]"
    }

    Write-Host "$($prefixes[$Type]) " -ForegroundColor $colors[$Type] -NoNewline
    Write-Host $Message
}

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-WingetAvailable {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-Winget {
    Write-Status "winget not found. Bootstrapping via PowerShell Gallery..." -Type Warning

    $originalProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    try {
        # Install NuGet provider if needed
        Write-Status "Installing NuGet package provider..." -Type Info
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop | Out-Null

        # Install WinGet client module
        Write-Status "Installing Microsoft.WinGet.Client module from PSGallery..." -Type Info
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -ErrorAction Stop | Out-Null

        # Bootstrap winget using Repair-WinGetPackageManager
        Write-Status "Repairing/Installing WinGet package manager..." -Type Info
        Repair-WinGetPackageManager -AllUsers -Force -ErrorAction Stop

        $ProgressPreference = $originalProgress

        # Verify installation
        if (Test-WingetAvailable) {
            Write-Status "winget installed successfully" -Type Success
            return $true
        }
        else {
            # Sometimes winget needs a path refresh
            Write-Status "Refreshing environment PATH..." -Type Info
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            if (Test-WingetAvailable) {
                Write-Status "winget installed successfully" -Type Success
                return $true
            }

            Write-Status "winget installation completed but command not found. Try restarting PowerShell." -Type Warning
            return $false
        }
    }
    catch {
        $ProgressPreference = $originalProgress
        Write-Status "Failed to install winget: $_" -Type Error
        return $false
    }
}

function Test-ProgramInstalled {
    param([hashtable]$Program)

    switch ($Program.CheckType) {
        "Appx" {
            $pkg = Get-AppxPackage -Name "*$($Program.AppxName)*" -ErrorAction SilentlyContinue
            return ($null -ne $pkg)
        }
        "Command" {
            try {
                $null = Get-Command $Program.Command -ErrorAction Stop
                return $true
            }
            catch {
                return $false
            }
        }
        default {
            return $false
        }
    }
}

function Install-Program {
    param([hashtable]$Program)

    Write-Status "Installing $($Program.Name)..." -Type Info

    try {
        $result = winget install --id $Program.WingetId --accept-source-agreements --accept-package-agreements --silent 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Status "$($Program.Name) installed successfully" -Type Success
            return $true
        }
        else {
            # Check if already installed (winget returns specific exit code)
            if ($result -match "already installed") {
                Write-Status "$($Program.Name) is already installed" -Type Success
                return $true
            }
            Write-Status "Failed to install $($Program.Name): $result" -Type Error
            return $false
        }
    }
    catch {
        Write-Status "Error installing $($Program.Name): $_" -Type Error
        return $false
    }
}

function Backup-ExistingConfig {
    param([string]$Path)

    if (Test-Path $Path) {
        $backupPath = "$Path.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

        # Check if it's already a symlink
        $item = Get-Item $Path -Force -ErrorAction SilentlyContinue
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Status "Removing existing symlink: $Path" -Type Info
            Remove-Item $Path -Force
            return $true
        }

        Write-Status "Backing up existing config to: $backupPath" -Type Info
        Move-Item -Path $Path -Destination $backupPath -Force
        return $true
    }
    return $true
}

function New-ConfigSymlink {
    param([hashtable]$Symlink)

    # Validate source exists
    if (-not (Test-Path $Symlink.Source)) {
        Write-Status "Source not found: $($Symlink.Source)" -Type Error
        return $false
    }

    # Ensure parent directory exists
    $parentDir = Split-Path -Parent $Symlink.Target
    if (-not (Test-Path $parentDir)) {
        Write-Status "Creating directory: $parentDir" -Type Info
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # Backup existing config
    if (-not (Backup-ExistingConfig -Path $Symlink.Target)) {
        return $false
    }

    # Create symlink
    try {
        if ($Symlink.Type -eq "Directory") {
            $null = New-Item -ItemType SymbolicLink -Path $Symlink.Target -Target $Symlink.Source -Force
        }
        else {
            $null = New-Item -ItemType SymbolicLink -Path $Symlink.Target -Target $Symlink.Source -Force
        }

        Write-Status "Created symlink: $($Symlink.Name)" -Type Success
        Write-Host "       $($Symlink.Target) -> $($Symlink.Source)" -ForegroundColor DarkGray
        return $true
    }
    catch {
        Write-Status "Failed to create symlink for $($Symlink.Name): $_" -Type Error
        return $false
    }
}

# ============================================================================
# Main Script
# ============================================================================

function Invoke-Setup {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Magenta
    Write-Host "  Windows Dev Environment Setup" -ForegroundColor Magenta
    Write-Host "======================================" -ForegroundColor Magenta
    Write-Host ""

    # Check for admin privileges
    if (-not (Test-Administrator)) {
        Write-Status "This script requires Administrator privileges for creating symlinks." -Type Error
        Write-Status "Please run PowerShell as Administrator and try again." -Type Info
        return
    }
    Write-Status "Running with Administrator privileges" -Type Success

    # Check for winget (and install if missing)
    if (-not $SkipInstall) {
        if (-not (Test-WingetAvailable)) {
            if (-not (Install-Winget)) {
                Write-Status "Cannot proceed without winget. Please restart PowerShell and try again." -Type Error
                return
            }
        }
        else {
            Write-Status "winget is available" -Type Success
        }
    }

    Write-Host ""

    # ========================================================================
    # Program Installation
    # ========================================================================

    if (-not $SkipInstall) {
        Write-Host "--- Program Installation ---" -ForegroundColor Yellow
        Write-Host ""

        foreach ($program in $Programs) {
            if (Test-ProgramInstalled -Program $program) {
                Write-Status "$($program.Name) is already installed" -Type Success
            }
            else {
                Write-Status "$($program.Name) not found" -Type Warning
                Install-Program -Program $program
            }
        }

        Write-Host ""
    }

    # ========================================================================
    # Symlink Creation
    # ========================================================================

    if (-not $SkipSymlinks) {
        Write-Host "--- Configuration Symlinks ---" -ForegroundColor Yellow
        Write-Host ""

        $symlinkResults = @()

        foreach ($symlink in $Symlinks) {
            $result = New-ConfigSymlink -Symlink $symlink
            $symlinkResults += @{ Name = $symlink.Name; Success = $result }
        }

        Write-Host ""
    }

    # ========================================================================
    # Summary
    # ========================================================================

    Write-Host "--- Setup Complete ---" -ForegroundColor Yellow
    Write-Host ""
    Write-Status "Dotfiles root: $DotfilesRoot" -Type Info
    Write-Host ""

    if (-not $SkipInstall) {
        Write-Host "Installed Programs:" -ForegroundColor Cyan
        foreach ($program in $Programs) {
            $installed = Test-ProgramInstalled -Program $program
            $status = if ($installed) { "[OK]" } else { "[MISSING]" }
            $color = if ($installed) { "Green" } else { "Red" }
            Write-Host "  $status $($program.Name)" -ForegroundColor $color
        }
        Write-Host ""
    }

    if (-not $SkipSymlinks) {
        Write-Host "Configuration Symlinks:" -ForegroundColor Cyan
        foreach ($symlink in $Symlinks) {
            $exists = Test-Path $symlink.Target
            $status = if ($exists) { "[OK]" } else { "[MISSING]" }
            $color = if ($exists) { "Green" } else { "Red" }
            Write-Host "  $status $($symlink.Name)" -ForegroundColor $color
        }
        Write-Host ""
    }

    Write-Status "You may need to restart your terminal for changes to take effect." -Type Info
    Write-Host ""
}

# Run the setup
Invoke-Setup
