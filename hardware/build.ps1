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
    all         everything below (default)
    pieces      just the six chess pieces
    gimbal      the pivot: hub + cap under "pin"/"bearing", the coupon under "magnet"
    board       the 8x8 panel, whole plus the four quarters
    board_test  the small Phase-0 test tile
    sheet       the steel sheet's cutting outline, as DXF for a laser shop
    mech        turntable, wall plate, drive pulley, frame corner
    variant     one named combination into its own folder (needs -Style/-Pivot)
    matrix      all six combinations, for comparing them side by side
    clean       delete the output folder

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
    [ValidateSet('monolith','familiar')]      [string] $Style,
    [ValidateSet('pin','magnet','bearing')]   [string] $Pivot,
    [string] $OpenScad
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$PIECES = @('pawn','knight','bishop','rook','queen','king')
$STYLES = @('monolith','familiar')
$PIVOTS = @('pin','magnet','bearing')

function Find-OpenScad {
    if ($OpenScad) {
        if (Test-Path $OpenScad) { return $OpenScad }
        throw "OpenSCAD not found at -OpenScad path: $OpenScad"
    }
    # Prefer openscad.COM over .EXE. The .exe is the GUI binary: it detaches,
    # so $LASTEXITCODE comes back empty and a failed render looks like a
    # success. The .com is the console shim that actually reports status.
    $cmd = Get-Command 'openscad' -ErrorAction SilentlyContinue
    if ($cmd) {
        $com = [IO.Path]::ChangeExtension($cmd.Source, '.com')
        if (Test-Path $com) { return $com }
        return $cmd.Source
    }
    $guesses = @(
        "$env:ProgramFiles\OpenSCAD\openscad.com",
        "$env:ProgramFiles\OpenSCAD\openscad.exe",
        "${env:ProgramFiles(x86)}\OpenSCAD\openscad.com",
        "${env:ProgramFiles(x86)}\OpenSCAD\openscad.exe",
        "$env:LOCALAPPDATA\Programs\OpenSCAD\openscad.com",
        "$env:LOCALAPPDATA\Programs\OpenSCAD\openscad.exe",
        "$env:ProgramFiles\OpenSCAD (Nightly)\openscad.com"
    )
    foreach ($g in $guesses) { if (Test-Path $g) { return $g } }
    throw @"
OpenSCAD not found. Install it from https://openscad.org and either add it to
PATH or pass the path explicitly:
    .\build.ps1 $Target -OpenScad 'C:\Program Files\OpenSCAD\openscad.exe'
"@
}

# One render. Fails loudly: OpenSCAD can exit 0 having written nothing, and a
# missing STL is much easier to catch here than three steps later in a slicer.
function Invoke-Scad {
    param([string[]] $Defines, [string] $OutFile, [string] $Source)
    $dir = Split-Path -Parent $OutFile
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    # NOT $args -- that is a PowerShell automatic variable, and splatting it
    # silently passes the caller's arguments instead of these.
    $scadArgs = @("-D", "`$fn=$Fn") + $Defines + @("-o", $OutFile, $Source)
    & $script:SCAD @scadArgs
    if ($LASTEXITCODE -ne 0) { throw "OpenSCAD failed ($LASTEXITCODE) on $Source -> $OutFile" }
    if (-not (Test-Path $OutFile)) { throw "OpenSCAD wrote nothing for $OutFile" }
    $kb = [math]::Round((Get-Item $OutFile).Length / 1KB, 1)
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
    Invoke-Scad -Defines @("-D", "QUARTER=\`"all\`"") -OutFile "$Out/board_panel.stl" -Source 'board_panel.scad'
    foreach ($q in @('bl','br','tl','tr')) {
        Invoke-Scad -Defines @("-D", "QUARTER=\`"$q\`"") -OutFile "$Out/board_panel_$q.stl" -Source 'board_panel.scad'
    }
}
function Build-Mech {
    Write-Host "mech:"
    Invoke-Scad -Defines @("-D", 'PART=\"wall\"')      -OutFile "$Out/hub_wall_plate.stl"   -Source 'rotation_hub.scad'
    Invoke-Scad -Defines @("-D", 'PART=\"turntable\"') -OutFile "$Out/hub_turntable.stl"    -Source 'rotation_hub.scad'
    Invoke-Scad -Defines @("-D", 'PART=\"pulley\"')    -OutFile "$Out/hub_drive_pulley.stl" -Source 'rotation_hub.scad'
    Invoke-Scad -Defines @("-D", 'PART=\"corner\"')    -OutFile "$Out/frame_corner.stl"     -Source 'frame.scad'
}
function Build-Variant { param([string] $S, [string] $P)
    $dir = Join-Path $Out "${S}_${P}"
    Write-Host "variant: $S x $P  ->  $dir"
    $sel = @("-D", "piece_style=\`"$S\`"", "-D", "pivot_type=\`"$P\`"")
    Build-Pieces -Dir $dir -Extra $sel
    Build-Gimbal -Dir $dir -Extra @("-D", "pivot_type=\`"$P\`"") -Name "gimbal_$P.stl"
}

if ($Target -eq 'clean') {
    if (Test-Path $Out) { Remove-Item -Recurse -Force $Out; Write-Host "removed $Out" }
    else { Write-Host "nothing to clean" }
    return
}

$script:SCAD = Find-OpenScad
Write-Host "OpenSCAD: $script:SCAD"
Write-Host "fn=$Fn  out=$Out`n"

switch ($Target) {
    'pieces'     { Build-Pieces }
    'gimbal'     { Build-Gimbal }
    'board'      { Build-Board }
    'board_test' { Write-Host "board_test:"; Invoke-Scad -Defines @("-D", "QUARTER=\`"test\`"") -OutFile "$Out/board_test.stl" -Source 'board_panel.scad' }
    'sheet'      { Write-Host "sheet:";      Invoke-Scad -Defines @("-D", "QUARTER=\`"sheet_dxf\`"") -OutFile "$Out/steel_sheet.dxf" -Source 'board_panel.scad' }
    'mech'       { Build-Mech }
    'variant'    {
        if (-not $Style -or -not $Pivot) {
            throw "variant needs both: .\build.ps1 variant -Style <$($STYLES -join '|')> -Pivot <$($PIVOTS -join '|')>"
        }
        Build-Variant -S $Style -P $Pivot
    }
    'matrix'     { foreach ($s in $STYLES) { foreach ($p in $PIVOTS) { Build-Variant -S $s -P $p } } }
    'all'        {
        Build-Pieces; Build-Gimbal; Build-Board
        Write-Host "board_test:"; Invoke-Scad -Defines @("-D", "QUARTER=\`"test\`"") -OutFile "$Out/board_test.stl" -Source 'board_panel.scad'
        Build-Mech
    }
}
Write-Host "`ndone -> $((Resolve-Path $Out).Path)"
