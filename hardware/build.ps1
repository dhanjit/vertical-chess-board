<#
.SYNOPSIS
    Render every printable part to STL. The Windows equivalent of the Makefile.

.DESCRIPTION
    Same targets, same outputs, same variant handling as ./Makefile -- but it
    needs neither `make` nor OpenSCAD on PATH, because Windows normally has
    neither. `make` is not shipped by Git Bash, and the OpenSCAD installer does
    not add itself to PATH, so `cd hardware && make` fails on a stock Windows
    box even when everything needed is installed.

    OpenSCAD is located automatically: PATH first, then the usual install
    directories. Override with -OpenScad if yours lives somewhere unusual.

.PARAMETER Target
    all         every printable part: pieces, gimbal, board, board_test, mech.
                NOT `sheet` -- that is a DXF for a laser shop, not a print, so
                ask for it by name. (Default.)
    pieces      just the six chess pieces
    gimbal      the pivot: hub + cap under "pin"/"bearing", the coupon under "magnet"
    board       the 8x8 panel, whole plus the four quarters
    board_test  the small Phase-0 test tile
    sheet       the steel sheet's cutting outline, as DXF for a laser shop
    mech        turntable, wall plate, drive pulley, frame corner
    variant     one named combination into its own folder (needs -Style/-Pivot)
    matrix      all six combinations, for comparing them side by side
    clean       delete the output folder

.PARAMETER Out
    Where the renders land. Relative paths are resolved against YOUR current
    directory, not against hardware\; the default is hardware\stl, which is
    what the Makefile writes and what .gitignore covers.

.PARAMETER Fn
    Curve smoothness. 96 is fine for checking; use 128 for final prints.

.EXAMPLE
    .\build.ps1
.EXAMPLE
    .\build.ps1 pieces -Fn 128
.EXAMPLE
    .\build.ps1 variant -Style familiar -Pivot magnet
.EXAMPLE
    .\build.ps1 matrix
#>
[CmdletBinding()]
param(
    [ValidateSet('all','pieces','gimbal','board','board_test','sheet','mech',
                 'variant','matrix','clean')]
    [string] $Target = 'all',
    [int]    $Fn     = 96,
    [string] $Out    = 'stl',
    # DELIBERATELY NOT [ValidateSet]. The style and pivot axes are extension
    # points -- "drop a file in styles/, add one entry to THE ENUM in
    # pieces.scad" -- and a ValidateSet here would reject a newly added name
    # before OpenSCAD ever saw it, which is stricter than the Makefile and
    # stricter than the documented recipe. The SCAD asserts in pieces.scad and
    # gravity_gimbal.scad are the real gate; let them do the rejecting.
    [string] $Style,
    [string] $Pivot,
    [string] $OpenScad
)

$ErrorActionPreference = 'Stop'

# PowerShell 7.3+ escapes native-command arguments itself. That turns the
# `PART=\"pawn\"` idiom below into a literal backslash-quote and every -D
# fails to parse. Ask for the 5.1 semantics the idiom is written against; on
# 5.1 itself this is just an unused variable, and it is script-scoped, so it
# does not leak into the caller's session.
$PSNativeCommandArgumentPassing = 'Legacy'

# Resolve -Out BEFORE moving to the script's own directory, or a relative path
# silently re-bases onto hardware\ -- which matters most for `clean`, whose
# Remove-Item -Recurse -Force would then delete a directory the caller never
# named. An -Out the caller typed means what the caller meant; the DEFAULT
# stays hardware\stl, to match the Makefile and .gitignore.
$Out = if ($PSBoundParameters.ContainsKey('Out')) {
    $p = $Out
    if (-not [IO.Path]::IsPathRooted($p)) { $p = Join-Path (Get-Location).ProviderPath $p }
    [IO.Path]::GetFullPath($p)
} else {
    Join-Path $PSScriptRoot 'stl'
}

$PIECES = @('pawn','knight','bishop','rook','queen','king')
# Mirrors of the enums in the SCAD sources -- see the extension-point note on
# -Style/-Pivot above. ADDING A STYLE OR A PIVOT TOUCHES FOUR PLACES: the SCAD
# file itself, "THE ENUM" in pieces.scad (style) or the dispatch in
# gravity_gimbal.scad (pivot), STYLES/PIVOTS in ./Makefile, and these two
# lines. Only `matrix` reads them; every other target passes the name straight
# through to OpenSCAD.
$STYLES = @('monolith','familiar')
$PIVOTS = @('pin','magnet','bearing')

# OpenSCAD ships two binaries side by side on Windows. openscad.exe is the GUI
# (WINDOWS-subsystem) build: it DETACHES in ~11 ms, so $LASTEXITCODE comes back
# empty and the very first render throws "OpenSCAD failed ()" on a success --
# while a genuine failure passes, against whatever stale STL was already there.
# openscad.com is the console shim that actually waits and reports status.
# Always prefer the .com, whatever we were handed.
function Resolve-ScadBinary([string] $Path) {
    if ([IO.Path]::GetExtension($Path) -eq '.exe') {
        $com = [IO.Path]::ChangeExtension($Path, '.com')
        if (Test-Path -LiteralPath $com) { return $com }
    }
    return $Path
}

function Find-OpenScad {
    if ($OpenScad) {
        if (Test-Path -LiteralPath $OpenScad) { return (Resolve-ScadBinary $OpenScad) }
        throw "OpenSCAD not found at -OpenScad path: $OpenScad"
    }
    $cmd = Get-Command 'openscad' -ErrorAction SilentlyContinue
    if ($cmd) { return (Resolve-ScadBinary $cmd.Source) }
    $guesses = @(
        "$env:ProgramFiles\OpenSCAD\openscad.com",
        "$env:ProgramFiles\OpenSCAD\openscad.exe",
        "${env:ProgramFiles(x86)}\OpenSCAD\openscad.com",
        "${env:ProgramFiles(x86)}\OpenSCAD\openscad.exe",
        "$env:LOCALAPPDATA\Programs\OpenSCAD\openscad.com",
        "$env:LOCALAPPDATA\Programs\OpenSCAD\openscad.exe",
        "$env:ProgramFiles\OpenSCAD (Nightly)\openscad.com"
    )
    foreach ($g in $guesses) { if (Test-Path -LiteralPath $g) { return (Resolve-ScadBinary $g) } }
    throw @"
OpenSCAD not found. Install it from https://openscad.org and either add it to
PATH or pass the path explicitly:
    .\build.ps1 $Target -OpenScad 'C:\Program Files\OpenSCAD\openscad.com'
"@
}

# Start-Process takes ONE command line, not an argv array, so the arguments have
# to be joined by hand. The -D defines already carry the `\"` escaping the C
# runtime expects (see the $PSNativeCommandArgumentPassing note above), so what
# is left here is exactly the outer quoting PowerShell's own legacy native-
# argument passing would have added, and nothing more: wrap anything with
# whitespace in it, and double a trailing backslash run so it cannot escape the
# closing quote. Escaping the embedded quotes a SECOND time here would reach
# OpenSCAD as a literal backslash and every -D would fail to parse.
function Format-NativeArg([string] $a) {
    if ($a -eq '')          { return '""' }
    if ($a -notmatch '\s')  { return $a }
    return '"' + ([regex]::Replace($a, '(\\+)$', '$1$1')) + '"'
}

# One render. Fails loudly: OpenSCAD can exit 0 having written nothing, and a
# missing STL is much easier to catch here than three steps later in a slicer.
function Invoke-Scad {
    param([string[]] $Defines, [string] $OutFile, [string] $Source)
    $dir = Split-Path -Parent $OutFile
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    # NOT $args -- that is a PowerShell automatic variable, and splatting it
    # silently passes the caller's arguments instead of these.
    $scadArgs = @("-D", "`$fn=$Fn") + $Defines + @("-o", $OutFile, $Source)
    if ($script:SCAD_DETACHES) {
        # No usable $LASTEXITCODE from a detaching GUI binary -- start it and
        # read the real exit code off the process object instead. -WorkingDirectory
        # is required: Start-Process uses the PROCESS cwd, which Push-Location
        # does not move, and $Source is named relative to hardware\.
        $line = ($scadArgs | ForEach-Object { Format-NativeArg $_ }) -join ' '
        $proc = Start-Process -FilePath $script:SCAD -ArgumentList $line `
                              -WorkingDirectory $PSScriptRoot -Wait -PassThru -NoNewWindow
        $code = $proc.ExitCode
    } else {
        & $script:SCAD @scadArgs
        $code = $LASTEXITCODE
    }
    if ($code -ne 0) { throw "OpenSCAD failed ($code) on $Source -> $OutFile" }
    if (-not (Test-Path -LiteralPath $OutFile)) { throw "OpenSCAD wrote nothing for $OutFile" }
    $kb = [math]::Round((Get-Item -LiteralPath $OutFile).Length / 1KB, 1)
    Write-Host ("  {0,-38} {1,8} KB" -f (Split-Path -Leaf $OutFile), $kb)
}

function Build-Pieces { param([string] $Dir = $Out, [string[]] $Extra = @())
    Write-Host "pieces:"
    foreach ($p in $PIECES) {
        Invoke-Scad -Defines ($Extra + @("-D", "PART=\`"$p\`"")) `
                    -OutFile (Join-Path $Dir "piece_$p.stl") -Source 'pieces.scad'
    }
}
function Build-Gimbal { param([string] $Dir = $Out, [string[]] $Extra = @(), [string] $Name = 'gimbal_testpair.stl')
    Write-Host "gimbal:"
    Invoke-Scad -Defines $Extra -OutFile (Join-Path $Dir $Name) -Source 'gravity_gimbal.scad'
}
function Build-Board {
    Write-Host "board:"
    Invoke-Scad -Defines @("-D", "QUARTER=\`"all\`"") -OutFile (Join-Path $Out 'board_panel.stl') -Source 'board_panel.scad'
    foreach ($q in @('bl','br','tl','tr')) {
        Invoke-Scad -Defines @("-D", "QUARTER=\`"$q\`"") -OutFile (Join-Path $Out "board_panel_$q.stl") -Source 'board_panel.scad'
    }
}
function Build-BoardTest {
    Write-Host "board_test:"
    Invoke-Scad -Defines @("-D", "QUARTER=\`"test\`"") -OutFile (Join-Path $Out 'board_test.stl') -Source 'board_panel.scad'
}
function Build-Mech {
    Write-Host "mech:"
    Invoke-Scad -Defines @("-D", 'PART=\"wall\"')      -OutFile (Join-Path $Out 'hub_wall_plate.stl')   -Source 'rotation_hub.scad'
    Invoke-Scad -Defines @("-D", 'PART=\"turntable\"') -OutFile (Join-Path $Out 'hub_turntable.stl')    -Source 'rotation_hub.scad'
    Invoke-Scad -Defines @("-D", 'PART=\"pulley\"')    -OutFile (Join-Path $Out 'hub_drive_pulley.stl') -Source 'rotation_hub.scad'
    Invoke-Scad -Defines @("-D", 'PART=\"corner\"')    -OutFile (Join-Path $Out 'frame_corner.stl')     -Source 'frame.scad'
}
# -GimbalFrom: gravity_gimbal.scad never reads piece_style, so across a `matrix`
# run the two styles at one pivot produce the IDENTICAL gimbal mesh. Hand the
# second one the first one's file and it is copied instead of re-rendered.
function Build-Variant { param([string] $S, [string] $P, [string] $GimbalFrom)
    $dir = Join-Path $Out "${S}_${P}"
    Write-Host "variant: $S x $P  ->  $dir"
    $sel = @("-D", "piece_style=\`"$S\`"", "-D", "pivot_type=\`"$P\`"")
    Build-Pieces -Dir $dir -Extra $sel
    if ($GimbalFrom -and (Test-Path -LiteralPath $GimbalFrom)) {
        $dest = Join-Path $dir "gimbal_$P.stl"
        Copy-Item -LiteralPath $GimbalFrom -Destination $dest
        Write-Host "gimbal:"
        Write-Host ("  {0,-38} {1,8}" -f "gimbal_$P.stl", "copied")
    } else {
        Build-Gimbal -Dir $dir -Extra @("-D", "pivot_type=\`"$P\`"") -Name "gimbal_$P.stl"
    }
}

# The renders name their sources relative to hardware\, so run from there --
# and put the caller's directory back on the way out, by whichever path we
# leave (return, throw, or Ctrl-C mid-render).
Push-Location -LiteralPath $PSScriptRoot
try {

if ($Target -eq 'clean') {
    if (Test-Path -LiteralPath $Out) { Remove-Item -Recurse -Force -LiteralPath $Out; Write-Host "removed $Out" }
    else { Write-Host "nothing to clean" }
    return
}

$script:SCAD = Find-OpenScad
# True only for an install with no .com next to the .exe -- see Resolve-ScadBinary.
$script:SCAD_DETACHES = ([IO.Path]::GetExtension($script:SCAD) -eq '.exe')
Write-Host "OpenSCAD: $script:SCAD"
if ($script:SCAD_DETACHES) {
    Write-Host "  (GUI binary, no console shim found -- running it via Start-Process for a real exit code)"
}
Write-Host "fn=$Fn  out=$Out`n"

switch ($Target) {
    'pieces'     { Build-Pieces }
    'gimbal'     { Build-Gimbal }
    'board'      { Build-Board }
    'board_test' { Build-BoardTest }
    'sheet'      { Write-Host "sheet:"; Invoke-Scad -Defines @("-D", "QUARTER=\`"sheet_dxf\`"") -OutFile (Join-Path $Out 'steel_sheet.dxf') -Source 'board_panel.scad' }
    'mech'       { Build-Mech }
    'variant'    {
        if (-not $Style -or -not $Pivot) {
            throw "variant needs both: .\build.ps1 variant -Style <$($STYLES -join '|')> -Pivot <$($PIVOTS -join '|')>"
        }
        Build-Variant -S $Style -P $Pivot
    }
    'matrix'     {
        # Pivot-major, so the style-independent gimbal is rendered once per
        # pivot (3) instead of once per combination (6).
        foreach ($p in $PIVOTS) {
            $first = $null
            foreach ($s in $STYLES) {
                Build-Variant -S $s -P $p -GimbalFrom $first
                if (-not $first) { $first = Join-Path (Join-Path $Out "${s}_${p}") "gimbal_$p.stl" }
            }
        }
    }
    'all'        {
        Build-Pieces; Build-Gimbal; Build-Board
        Build-BoardTest
        Build-Mech
    }
}
Write-Host "`ndone -> $Out"

}
finally { Pop-Location }
