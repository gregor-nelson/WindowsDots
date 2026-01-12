
$env:Path = "C:\Users\gregor\AppData\Roaming\npm;" + $env:Path

function prompt {
    # Store the exit code of the last command
    $lastExitCode = $?

    # Define colors using ANSI escape codes (from first profile)
    $red = "$([char]0x1b)[91m"
    $yellow = "$([char]0x1b)[93m"
    $green = "$([char]0x1b)[92m"
    $blue = "$([char]0x1b)[94m"
    $magenta = "$([char]0x1b)[95m"
    $reset = "$([char]0x1b)[0m"
    $bold = "$([char]0x1b)[1m"

    # Get username and computer name (combined approaches)
    $username = $env:USERNAME
    $computerName = [System.Net.Dns]::GetHostName()

    # Get current path with tilde replacement (merged logic)
    $currentPath = (Get-Location).Path
    $homeDir = $env:HOME ?? $env:USERPROFILE
    if ($currentPath.ToLower().StartsWith($homeDir.ToLower())) {
        $currentPath = "~" + $currentPath.Substring($homeDir.Length)
    }

    # Build the prompt string with enhanced formatting
    $promptString = "$bold$red[$yellow$username$green@$blue$computerName $magenta$currentPath$red]$reset$bold$ $reset"

    return $promptString
}

function Get-NerdFontIcon {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileSystemInfo]$Item
    )

    # File type checks
    $isDirectory = $Item.PSIsContainer
    $isSymLink = $Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint
    $isExecutable = $Item.Extension -in @('.exe', '.bat', '.cmd', '.ps1', '.vbs', '.msi', '.sh') -or 
                   (($Item.Attributes -band [System.IO.FileAttributes]::Archive) -and 
                   ($Item.Attributes -band [System.IO.FileAttributes]::System))
    
    # Check file permissions/attributes
    $isReadOnly = $Item.Attributes -band [System.IO.FileAttributes]::ReadOnly
    $isHidden = $Item.Attributes -band [System.IO.FileAttributes]::Hidden
    $isSystem = $Item.Attributes -band [System.IO.FileAttributes]::System
    
    # Special file types
    if ($isSymLink) { return "" }
    if ($isDirectory) {
        if ($isReadOnly) { return "" }
        return "" }
    if ($isExecutable) { return "" }
    
    # Get lowercase filename and extension
    $extension = if ($Item.Extension) { $Item.Extension.ToLower() } else { "" }
    $fileName = $Item.Name.ToLower()
    
    # Check for special filenames (keeping all patterns from original)
    switch -Regex ($fileName) {
        "^gruntfile\.(js|coffee|ls)$" { return "" }
        "^gulpfile\.(js|coffee|ls)$" { return "" }
        "^mix\.lock$" { return "" }
        "^dropbox$" { return "" }
        "^\.ds_store$" { return "" }
        "^\.gitconfig$" { return "" }
        "^\.gitignore$" { return "" }
        "^\.gitattributes$" { return "" }
        "^\.gitlab-ci\.yml$" { return "" }
        "^\.bashrc$" { return "" }
        "^\.zshrc$" { return "" }
        "^\.zshenv$" { return "" }
        "^\.zprofile$" { return "" }
        "^\.vimrc$" { return "" }
        "^\.gvimrc$" { return "" }
        "^_vimrc$" { return "" }
        "^_gvimrc$" { return "" }
        "^\.bashprofile$" { return "" }
        "^favicon\.ico$" { return "" }
        "^license$" { return "" }
        "^node_modules$" { return "" }
        "^react\.jsx$" { return "" }
        "^procfile$" { return "" }
        "^dockerfile$" { return "" }
        "^docker-compose\.yml$" { return "" }
        "^rakefile$" { return "" }
        "^config\.ru$" { return "" }
        "^gemfile$" { return "" }
        "^makefile$" { return "" }
        "^cmakelists\.txt$" { return "" }
        "^robots\.txt$" { return "ﮧ" }
        "^Gruntfile\.(js|coffee|ls)$" { return "" }
        "^Gulpfile\.(js|coffee|ls)$" { return "" }
        "^Dropbox$" { return "" }
        "^\.DS_Store$" { return "" }
        "^LICENSE$" { return "" }
        "^React\.jsx$" { return "" }
        "^Procfile$" { return "" }
        "^Dockerfile$" { return "" }
        "^Docker-compose\.yml$" { return "" }
        "^Rakefile$" { return "" }
        "^Gemfile$" { return "" }
        "^Makefile$" { return "" }
        "^CMakeLists\.txt$" { return "" }
        "jquery\.min\.js$" { return "" }
        "angular\.min\.js$" { return "" }
        "backbone\.min\.js$" { return "" }
        "require\.min\.js$" { return "" }
        "materialize\.min\.(js|css)$" { return "" }
        "mootools\.min\.js$" { return "" }
        "^vimrc$" { return "" }
        "^Vagrantfile$" { return "" }
    }
    
    # File types by extension (keeping all from original)
    switch ($extension) {
        ".styl" { return "" }
        ".sass" { return "" }
        ".scss" { return "" }
        ".htm" { return "" }
        ".html" { return "" }
        ".slim" { return "" }
        ".haml" { return "" }
        ".ejs" { return "" }
        ".css" { return "" }
        ".less" { return "" }
        ".md" { return "" }
        ".mdx" { return "" }
        ".markdown" { return "" }
        ".rmd" { return "" }
        ".json" { return "" }
        ".webmanifest" { return "" }
        ".js" { return "" }
        ".mjs" { return "" }
        ".jsx" { return "" }
        ".rb" { return "" }
        ".gemspec" { return "" }
        ".rake" { return "" }
        ".php" { return "" }
        ".py" { return "" }
        ".pyc" { return "" }
        ".pyo" { return "" }
        ".pyd" { return "" }
        ".coffee" { return "" }
        ".mustache" { return "" }
        ".hbs" { return "" }
        ".conf" { return "" }
        ".ini" { return "" }
        ".yml" { return "" }
        ".yaml" { return "" }
        ".toml" { return "" }
        ".bat" { return "" }
        ".mk" { return "" }
        ".jpg" { return "" }
        ".jpeg" { return "" }
        ".bmp" { return "" }
        ".png" { return "" }
        ".webp" { return "" }
        ".gif" { return "" }
        ".ico" { return "" }
        ".twig" { return "" }
        ".cpp" { return "" }
        ".c++" { return "" }
        ".cxx" { return "" }
        ".cc" { return "" }
        ".cp" { return "" }
        ".c" { return "" }
        ".cs" { return "" }
        ".h" { return "" }
        ".hh" { return "" }
        ".hpp" { return "" }
        ".hxx" { return "" }
        ".hs" { return "" }
        ".lhs" { return "" }
        ".nix" { return "" }
        ".lua" { return "" }
        ".java" { return "" }
        ".sh" { return "" }
        ".fish" { return "" }
        ".bash" { return "" }
        ".zsh" { return "" }
        ".ksh" { return "" }
        ".csh" { return "" }
        ".awk" { return "" }
        ".ps1" { return "" }
        ".ml" { return "λ" }
        ".mli" { return "λ" }
        ".diff" { return "" }
        ".db" { return "" }
        ".sql" { return "" }
        ".dump" { return "" }
        ".clj" { return "" }
        ".cljc" { return "" }
        ".cljs" { return "" }
        ".edn" { return "" }
        ".scala" { return "" }
        ".go" { return "" }
        ".dart" { return "" }
        ".xul" { return "" }
        ".sln" { return "" }
        ".suo" { return "" }
        ".pl" { return "" }
        ".pm" { return "" }
        ".t" { return "" }
        ".rss" { return "" }
        ".f#" { return "" }
        ".fsscript" { return "" }
        ".fsx" { return "" }
        ".fs" { return "" }
        ".fsi" { return "" }
        ".rs" { return "" }
        ".rlib" { return "" }
        ".d" { return "" }
        ".erl" { return "" }
        ".hrl" { return "" }
        ".ex" { return "" }
        ".exs" { return "" }
        ".eex" { return "" }
        ".leex" { return "" }
        ".heex" { return "" }
        ".vim" { return "" }
        ".ai" { return "" }
        ".psd" { return "" }
        ".psb" { return "" }
        ".ts" { return "" }
        ".tsx" { return "" }
        ".jl" { return "" }
        ".pp" { return "" }
        ".vue" { return "﵂" }
        ".elm" { return "" }
        ".swift" { return "" }
        ".xcplayground" { return "" }
        ".tex" { return "ﭨ" }
        ".r" { return "ﳒ" }
        ".rproj" { return "鉶" }
        ".sol" { return "ﲹ" }
        ".pem" { return "" }
        ".tar" { return "" }
        ".tgz" { return "" }
        ".arc" { return "" }
        ".arj" { return "" }
        ".taz" { return "" }
        ".lha" { return "" }
        ".lz4" { return "" }
        ".lzh" { return "" }
        ".lzma" { return "" }
        ".tlz" { return "" }
        ".txz" { return "" }
        ".tzo" { return "" }
        ".t7z" { return "" }
        ".zip" { return "" }
        ".z" { return "" }
        ".dz" { return "" }
        ".gz" { return "" }
        ".lrz" { return "" }
        ".lz" { return "" }
        ".lzo" { return "" }
        ".xz" { return "" }
        ".zst" { return "" }
        ".tzst" { return "" }
        ".bz2" { return "" }
        ".bz" { return "" }
        ".tbz" { return "" }
        ".tbz2" { return "" }
        ".tz" { return "" }
        ".deb" { return "" }
        ".rpm" { return "" }
        ".jar" { return "" }
        ".war" { return "" }
        ".ear" { return "" }
        ".sar" { return "" }
        ".rar" { return "" }
        ".alz" { return "" }
        ".ace" { return "" }
        ".zoo" { return "" }
        ".cpio" { return "" }
        ".7z" { return "" }
        ".rz" { return "" }
        ".cab" { return "" }
        ".wim" { return "" }
        ".swm" { return "" }
        ".dwm" { return "" }
        ".esd" { return "" }
        ".mjpg" { return "" }
        ".mjpeg" { return "" }
        ".pbm" { return "" }
        ".pgm" { return "" }
        ".ppm" { return "" }
        ".tga" { return "" }
        ".xbm" { return "" }
        ".xpm" { return "" }
        ".tif" { return "" }
        ".tiff" { return "" }
        ".svg" { return "" }
        ".svgz" { return "" }
        ".mng" { return "" }
        ".pcx" { return "" }
        ".mov" { return "" }
        ".mpg" { return "" }
        ".mpeg" { return "" }
        ".m2v" { return "" }
        ".mkv" { return "" }
        ".webm" { return "" }
        ".ogm" { return "" }
        ".mp4" { return "" }
        ".m4v" { return "" }
        ".mp4v" { return "" }
        ".vob" { return "" }
        ".qt" { return "" }
        ".nuv" { return "" }
        ".wmv" { return "" }
        ".asf" { return "" }
        ".rm" { return "" }
        ".rmvb" { return "" }
        ".flc" { return "" }
        ".avi" { return "" }
        ".fli" { return "" }
        ".flv" { return "" }
        ".gl" { return "" }
        ".dl" { return "" }
        ".xcf" { return "" }
        ".xwd" { return "" }
        ".yuv" { return "" }
        ".cgm" { return "" }
        ".emf" { return "" }
        ".ogv" { return "" }
        ".ogx" { return "" }
        ".aac" { return "" }
        ".au" { return "" }
        ".flac" { return "" }
        ".m4a" { return "" }
        ".mid" { return "" }
        ".midi" { return "" }
        ".mka" { return "" }
        ".mp3" { return "" }
        ".mpc" { return "" }
        ".ogg" { return "" }
        ".ra" { return "" }
        ".wav" { return "" }
        ".oga" { return "" }
        ".opus" { return "" }
        ".spx" { return "" }
        ".xspf" { return "" }
        ".pdf" { return "" }
        default { return "" }
    }
}

function Format-FileSize {
    param (
        [Parameter(Mandatory=$true)]
        [long]$Size
    )
    
    if ($Size -lt 1KB) {
        return "$Size B"
    }
    elseif ($Size -lt 1MB) {
        return "{0:N1} KB" -f ($Size / 1KB)
    }
    elseif ($Size -lt 1GB) {
        return "{0:N1} MB" -f ($Size / 1MB)
    }
    else {
        return "{0:N1} GB" -f ($Size / 1GB)
    }
}

function Get-FileListingWithIcons {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$Path = ".",
        [switch]$Force
    )
    
    begin {
        $originalForeground = $Host.UI.RawUI.ForegroundColor
        $modeWidth = 6
        $dateWidth = 19
        $sizeWidth = 10
    }
    
    process {
        foreach ($p in $Path) {
            try {
                $params = @{ Path = $p }
                if ($Force) { $params.Force = $true }
                $PSBoundParameters.GetEnumerator() | Where-Object { $_.Key -ne "Path" -and $_.Key -ne "Force" } | ForEach-Object {
                    $params[$_.Key] = $_.Value
                }
                
                $items = Get-ChildItem @params
                
                foreach ($item in $items) {
                    $icon = Get-NerdFontIcon -Item $item
                    $mode = ""
                    if ($item.PSIsContainer) { $mode += "d" } else { $mode += "-" }
                    if ($item.Attributes -band [System.IO.FileAttributes]::ReadOnly) { $mode += "r" } else { $mode += "-" }
                    if ($item.Attributes -band [System.IO.FileAttributes]::Hidden) { $mode += "h" } else { $mode += "-" }
                    if ($item.Attributes -band [System.IO.FileAttributes]::System) { $mode += "s" } else { $mode += "-" }
                    if ($item.Attributes -band [System.IO.FileAttributes]::Archive) { $mode += "a" } else { $mode += "-" }
                    
                    $lastWrite = $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
                    $size = if ($item.PSIsContainer) { "" } else { Format-FileSize -Size $item.Length }
                    
                    $color = switch -Regex ($item.Extension.ToLower()) {
                        "\.(exe|bat|cmd|ps1|psm1|psd1)$" { "Green" }
                        "\.(zip|rar|7z|tar|gz|bz2)$" { "Red" }
                        "\.(jpg|png|gif|bmp|ico|svg|webp)$" { "Magenta" }
                        "\.(mp3|wav|ogg|flac|m4a)$" { "Yellow" }
                        "\.(mp4|avi|mkv|mov|wmv)$" { "Yellow" }
                        "\.(doc|docx|xls|xlsx|ppt|pptx|pdf)$" { "Yellow" }
                        "\.(js|ts|py|rb|java|c|cpp|go|rs)$" { "DarkYellow" }
                        default { if ($item.PSIsContainer) { "Cyan" } else { "White" } }
                    }
                    
                    Write-Host ("{0,-$modeWidth} " -f $mode) -NoNewline -ForegroundColor DarkGray
                    Write-Host ("{0,-$dateWidth} " -f $lastWrite) -NoNewline -ForegroundColor DarkGray
                    Write-Host ("{0,$sizeWidth} " -f $size) -NoNewline -ForegroundColor DarkGray
                    Write-Host "$icon " -NoNewline -ForegroundColor $color
                    Write-Host $item.Name -ForegroundColor $color
                }
            }
            catch {
                Write-Error "Error accessing path '$p': $_"
            }
        }
    }
    
    end {
        $Host.UI.RawUI.ForegroundColor = $originalForeground
    }
}

Set-Alias -Name ls -Value Get-FileListingWithIcons -Option AllScope -Force

function Touch-File {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Path
    )
    foreach ($file in $Path) {
        if (Test-Path $file) {
            (Get-Item $file).LastWriteTime = Get-Date
        } else {
            New-Item -ItemType File -Path $file -Force | Out-Null
        }
    }
}

Set-Alias -Name touch -Value Touch-File


function Connect-Watch { ssh -C debian@51.79.254.133 }
Set-Alias -Name sshwatch -Value Connect-Watch

function Connect-Pdf { ssh -C debian@51.178.139.7 }
Set-Alias -Name server -Value Connect-Pdf

function Dev-Start {python.exe C:\Users\gregor\Downloads\Dev\MotCheck-UK\configs\dev_start.py}
Set-Alias -Name mot_server -Value Dev-Start
