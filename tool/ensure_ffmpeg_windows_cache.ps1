[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string] $RepoRoot,
    [Parameter(Mandatory = $true)][string] $ArchiveSha256,
    [Parameter(Mandatory = $true)][string] $DllSha256
)

$ErrorActionPreference = 'Stop'
$bundleName = 'bundle-base-windows-x86_64-shared-lgpl'
$windowsRoot = Join-Path $RepoRoot '.dart_tool\hooks_runner\shared\ffmpeg_kit_extended_flutter\build\ffmpeg_kit_cache\windows'
$archivePath = Join-Path $windowsRoot "$bundleName.zip"
$extractRoot = Join-Path $windowsRoot $bundleName
$dllRelative = "$bundleName/bin/libffmpegkit.dll"
$dllPath = Join-Path $extractRoot "$bundleName\bin\libffmpegkit.dll"
$markerPath = Join-Path $extractRoot '.extract_complete'

function Test-Hash {
    param([string] $Path, [string] $Expected)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    $sha256 = [Security.Cryptography.SHA256]::Create()
    $stream = [IO.File]::OpenRead($Path)
    try {
        $actual = [BitConverter]::ToString($sha256.ComputeHash($stream)).Replace('-', '')
        return $actual.Equals($Expected, [StringComparison]::OrdinalIgnoreCase)
    } finally {
        $stream.Dispose()
        $sha256.Dispose()
    }
}

function Assert-NoReparsePoint {
    param([string] $Path)
    if (Test-Path -LiteralPath $Path) {
        $item = Get-Item -LiteralPath $Path -Force
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing FFmpeg cache reparse point: $Path"
        }
    }
}

$repoFull = [IO.Path]::GetFullPath($RepoRoot).TrimEnd('\')
$windowsFull = [IO.Path]::GetFullPath($windowsRoot)
if (-not $windowsFull.StartsWith("$repoFull\.dart_tool\", [StringComparison]::OrdinalIgnoreCase)) {
    throw 'FFmpeg Windows cache must be inside this repository'
}
$walk = $repoFull
foreach ($part in @('.dart_tool', 'hooks_runner', 'shared', 'ffmpeg_kit_extended_flutter', 'build', 'ffmpeg_kit_cache', 'windows')) {
    $walk = Join-Path $walk $part
    Assert-NoReparsePoint -Path $walk
}

if ($ArchiveSha256 -notmatch '^[a-fA-F0-9]{64}$' -or $DllSha256 -notmatch '^[a-fA-F0-9]{64}$') {
    throw 'Invalid FFmpeg Windows cache digest'
}
if (-not (Test-Hash -Path $archivePath -Expected $ArchiveSha256)) {
    throw 'FFmpeg Windows archive is absent or differs from the pinned SHA-256'
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    $extractFull = [IO.Path]::GetFullPath($extractRoot).TrimEnd('\')
    $extractPrefix = "$extractFull\"
    $entries = @()
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $hasDll = $false
    foreach ($entry in $zip.Entries) {
        $name = $entry.FullName
        if (-not $name.StartsWith("$bundleName/", [StringComparison]::Ordinal) -or
            $name.Contains('\') -or $name.Contains(':') -or $name -match '[\x00-\x1f]' -or
            -not $seen.Add($name)) {
            throw 'Unsafe or duplicate FFmpeg Windows archive entry'
        }
        $parts = $name.Split('/')
        for ($i = 0; $i -lt $parts.Length; $i++) {
            if ($parts[$i] -eq '.' -or $parts[$i] -eq '..' -or
                ($parts[$i] -eq '' -and $i -ne $parts.Length - 1)) {
                throw 'Unsafe FFmpeg Windows archive path'
            }
        }
        $fileType = ($entry.ExternalAttributes -shr 16) -band 0xF000
        if ($fileType -eq 0xA000) { throw 'FFmpeg Windows archive contains a symbolic link' }
        $destination = [IO.Path]::GetFullPath((Join-Path $extractRoot $name.Replace('/', '\')))
        if (-not $destination.StartsWith($extractPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'FFmpeg Windows archive path escaped the extraction cache'
        }
        $entries += [pscustomobject]@{ Entry = $entry; Path = $destination }
        if ($name -eq $dllRelative) { $hasDll = $true }
    }
    if (-not $hasDll) { throw 'FFmpeg Windows archive is missing libffmpegkit.dll' }

    Assert-NoReparsePoint -Path $extractRoot
    Assert-NoReparsePoint -Path $dllPath
    Assert-NoReparsePoint -Path $markerPath
    if ((Test-Path -LiteralPath $markerPath -PathType Leaf) -and
        (Test-Hash -Path $dllPath -Expected $DllSha256)) {
        Write-Host 'Verified FFmpeg Windows hook extraction'
        return
    }

    # The hook trusts marker presence without checking the DLL. Move a stale
    # marker aside before repairing; never leave a success marker on failure.
    if (Test-Path -LiteralPath $markerPath) {
        Move-Item -LiteralPath $markerPath -Destination "$markerPath.invalid-$([guid]::NewGuid().ToString('N'))"
    }
    foreach ($item in $entries) {
        $destination = $item.Path
        $parent = Split-Path -Parent $destination
        $walk = $extractFull
        $relative = $destination.Substring($extractPrefix.Length)
        foreach ($part in $relative.Split('\')) {
            if ($part -eq '') { continue }
            $walk = Join-Path $walk $part
            Assert-NoReparsePoint -Path $walk
        }
        if ($item.Entry.FullName.EndsWith('/')) {
            New-Item -ItemType Directory -Path $destination -Force | Out-Null
            continue
        }
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        $inputStream = $item.Entry.Open()
        try {
            $outputStream = [IO.File]::Open($destination, [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::None)
            try { $inputStream.CopyTo($outputStream) } finally { $outputStream.Dispose() }
        } finally {
            $inputStream.Dispose()
        }
    }
    if (-not (Test-Hash -Path $dllPath -Expected $DllSha256)) {
        throw 'FFmpeg Windows extracted DLL differs from the pinned SHA-256'
    }
    Set-Content -LiteralPath $markerPath -Value $DllSha256.ToLowerInvariant() -Encoding ASCII -NoNewline
    Write-Host 'Verified FFmpeg Windows hook extraction'
} finally {
    $zip.Dispose()
}
