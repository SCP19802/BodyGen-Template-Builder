@echo off
setlocal DisableDelayedExpansion

if "%~1"=="" (
    echo Drag one or more BodySlide XML preset files onto this BAT file.
    echo The generated file will be saved as templates.ini beside this BAT.
    powershell.exe -NoLogo -NoProfile -Command "Write-Host 'Press any key to continue . . .' -NoNewline; do { $key=[Console]::ReadKey($true) } while ($key.Key -eq [ConsoleKey]::PrintScreen); Write-Host"
    exit /b 1
)

set "BODYGEN_BUILDER_SELF=%~f0"
set "BODYGEN_INPUT_COUNT=0"
:collect
if "%~1"=="" goto run
set /a BODYGEN_INPUT_COUNT+=1 >nul
set "BODYGEN_INPUT_%BODYGEN_INPUT_COUNT%=%~1"
shift
goto collect
:run
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "try { $self=$env:BODYGEN_BUILDER_SELF; $lines=[System.IO.File]::ReadAllLines($self); $marker=[System.Array]::IndexOf($lines,':__PS__'); if($marker -lt 0){throw 'Embedded script marker not found.'}; $code=($lines[($marker+1)..($lines.Length-1)] -join [Environment]::NewLine); & ([scriptblock]::Create($code)) } catch { Write-Host $_.Exception.Message -ForegroundColor Red; exit 2 }"
set "exitCode=%ERRORLEVEL%"
if not defined BODYGEN_NO_PAUSE powershell.exe -NoLogo -NoProfile -Command "Write-Host 'Press any key to continue . . .' -NoNewline; do { $key=[Console]::ReadKey($true) } while ($key.Key -eq [ConsoleKey]::PrintScreen); Write-Host"
exit /b %exitCode%

:__PS__
$ErrorActionPreference = 'Stop'
$templatePath = Join-Path (Split-Path -Parent $self) 'templates.ini'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$files = @(for ($i = 1; $i -le [int]$env:BODYGEN_INPUT_COUNT; $i++) { [Environment]::GetEnvironmentVariable('BODYGEN_INPUT_' + $i) })

if ($files.Count -eq 0) {
    Write-Host 'No readable input files were supplied.' -ForegroundColor Red
    exit 2
}

$lines = [System.Collections.Generic.List[string]]::new()
if (Test-Path -LiteralPath $templatePath -PathType Leaf) {
    foreach ($line in [System.IO.File]::ReadAllLines($templatePath)) { [void]$lines.Add($line) }
}

$processed = 0
$failed = 0
foreach ($file in $files) {
    if ([System.IO.Path]::GetExtension($file) -ine '.xml') {
        Write-Host ("Skipping non-XML file: {0}" -f $file) -ForegroundColor Yellow
        $failed++
        continue
    }
    try {
        $xml = New-Object System.Xml.XmlDocument
        $xml.PreserveWhitespace = $false
        $xml.Load($file)
        $presets = @($xml.SelectNodes('/SliderPresets/Preset'))
        if ($presets.Count -eq 0) { throw 'No /SliderPresets/Preset elements found.' }
        foreach ($preset in $presets) {
            $name = [string]$preset.GetAttribute('name')
            if ([string]::IsNullOrWhiteSpace($name)) { throw 'A preset has no name attribute.' }
            $parts = [System.Collections.Generic.List[string]]::new()
            foreach ($slider in @($preset.SelectNodes('./SetSlider'))) {
                $sliderName = [string]$slider.GetAttribute('name')
                $rawValue = [string]$slider.GetAttribute('value')
                if ([string]::IsNullOrWhiteSpace($sliderName) -or [string]::IsNullOrWhiteSpace($rawValue)) { throw ("Preset '{0}' contains an incomplete SetSlider element." -f $name) }
                $percent = [decimal]::Parse($rawValue, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture)
                $value = ($percent / 100D).ToString('0.0############################', [Globalization.CultureInfo]::InvariantCulture)
                [void]$parts.Add(('{0}@{1}' -f $sliderName, $value))
            }
            if ($parts.Count -eq 0) { throw ("Preset '{0}' contains no SetSlider elements." -f $name) }
            $newLine = '{0}={1}' -f $name, ($parts -join ',')
            $found = $false
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match '^\s*([^=]+)=') {
                    if ($Matches[1].Trim() -ceq $name) { $lines[$i] = $newLine; $found = $true; break }
                }
            }
            if (-not $found) { [void]$lines.Add($newLine) }
            Write-Host ("Added {0} from {1}" -f $name, [System.IO.Path]::GetFileName($file)) -ForegroundColor Green
            $processed++
        }
    } catch {
        Write-Host ("Failed {0}: {1}" -f $file, $_.Exception.Message) -ForegroundColor Red
        $failed++
    }
}

[System.IO.File]::WriteAllLines($templatePath, $lines, $utf8NoBom)
Write-Host ("Saved {0} preset(s) to {1}" -f $processed, $templatePath) -ForegroundColor Cyan
if ($failed -gt 0) { Write-Host ("{0} input(s) failed or were skipped." -f $failed) -ForegroundColor Yellow; exit 3 }
exit 0
