param(
    [string]$GodotPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Stop-Validation {
    param(
        [string]$StepName,
        [int]$ExitCode,
        [string]$Message = ""
    )

    if ($Message) {
        Write-Host $Message
    }
    Write-Host ("VALIDATION_STEP_FAIL: {0} (exit code {1})" -f $StepName, $ExitCode)
    exit $(if ($ExitCode -eq 0) { 1 } else { $ExitCode })
}

function Invoke-ValidationStep {
    param(
        [string]$StepName,
        [string]$Executable,
        [string[]]$Arguments
    )

    Write-Host ("[RUN] {0}" -f $StepName)
    $effectiveArguments = @($Arguments)
    if ($Executable -eq $script:godotExecutable) {
        # Godot otherwise writes under user://logs. Sandboxed and CI-style
        # runners may not have a writable roaming profile, and Godot 4.6.3 can
        # crash while rotating that log. Keep every validator log inside the
        # ignored workspace output instead.
        $validationLogRoot = Join-Path $script:repoRoot "output/validation-logs"
        New-Item -ItemType Directory -Path $validationLogRoot -Force | Out-Null
        $safeStepName = $StepName -replace '[^A-Za-z0-9._-]', '_'
        $validationLogPath = Join-Path $validationLogRoot ("{0}.log" -f $safeStepName)
        $effectiveArguments = @("--log-file", $validationLogPath) + $effectiveArguments
    }
    try {
        & $Executable @effectiveArguments
    } catch {
        Stop-Validation -StepName $StepName -ExitCode 1 -Message $_.Exception.Message
    }
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        Stop-Validation -StepName $StepName -ExitCode $exitCode
    }
    Write-Host ("[PASS] {0}" -f $StepName)
}

if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    $GodotPath = Join-Path $repoRoot ".tools/godot/Godot_v4.6.3-stable_win64_console.exe"
} elseif (-not [System.IO.Path]::IsPathRooted($GodotPath)) {
    $GodotPath = Join-Path $repoRoot $GodotPath
}

if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    Stop-Validation -StepName "godot version" -ExitCode 127 -Message ("Godot executable not found: {0}" -f $GodotPath)
}
$godotExecutable = (Resolve-Path -LiteralPath $GodotPath).Path

$pythonCommand = Get-Command python -CommandType Application -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($null -eq $pythonCommand) {
    Stop-Validation -StepName "python availability" -ExitCode 127 -Message "python executable was not found."
}
$pythonExecutable = $pythonCommand.Source

Write-Host "[RUN] godot version"
try {
    $versionOutput = & $godotExecutable --version
} catch {
    Stop-Validation -StepName "godot version" -ExitCode 1 -Message $_.Exception.Message
}
$versionExitCode = $LASTEXITCODE
foreach ($line in @($versionOutput)) {
    Write-Host $line
}
if ($versionExitCode -ne 0) {
    Stop-Validation -StepName "godot version" -ExitCode $versionExitCode
}
$versionText = (@($versionOutput) -join "`n").Trim()
if ($versionText -notmatch '^4\.6\.3(?:\.|$)') {
    Stop-Validation -StepName "godot version" -ExitCode 1 -Message ("Expected Godot 4.6.3, got: {0}" -f $versionText)
}
Write-Host "[PASS] godot version"

Push-Location $repoRoot
try {
    Invoke-ValidationStep "planning validator" $pythonExecutable @(
        "scripts/validate_planning_repository.py"
    )
    Invoke-ValidationStep "content validator" $pythonExecutable @(
        "tools/validators/validate_content.py",
        "--root",
        $repoRoot
    )
    Invoke-ValidationStep "production static validator" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tools/validators/validate_all.gd"
    )
    Invoke-ValidationStep "editor import and parse" $godotExecutable @(
        "--headless",
        "--editor",
        "--path",
        $repoRoot,
        "--quit-after",
        "10"
    )
    Invoke-ValidationStep "boot" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--scene",
        "res://tests/scenes/test_boot.tscn"
    )
    Invoke-ValidationStep "app state" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_app_state.gd"
    )
    Invoke-ValidationStep "save service" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_save_service.gd"
    )
    Invoke-ValidationStep "runtime save adapter" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_runtime_save_adapter.gd"
    )
    Invoke-ValidationStep "shell screens" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_shell_screens.gd"
    )
    Invoke-ValidationStep "UI interactions" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_ui_interactions.gd"
    )
    Invoke-ValidationStep "runtime audio" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_runtime_audio_player.gd"
    )
    Invoke-ValidationStep "chapter visual catalog" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_ch01_visual_catalog.gd"
    )
    Invoke-ValidationStep "cinematic directors" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--scene",
        "res://tests/scenes/test_cinematic_directors.tscn"
    )
    Invoke-ValidationStep "cinematic presenter" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_cinematic_presenter.gd"
    )
    Invoke-ValidationStep "chapter end screen" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/unit/test_chapter_end_screen.gd"
    )
    Invoke-ValidationStep "story runtime" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/integration/test_story_runtime.gd"
    )
    Invoke-ValidationStep "aggregate sanity" $godotExecutable @(
        "--headless",
        "--path",
        $repoRoot,
        "--script",
        "res://tests/test_runner.gd"
    )

    $testsRoot = Join-Path $repoRoot "tests"
    $mainFlowScene = Get-ChildItem -LiteralPath $testsRoot -Recurse -File -Filter "*.tscn" |
        Where-Object { $_.BaseName -match '(?i)main.*flow|flow.*main' } |
        Select-Object -First 1
    $mainFlowScript = Get-ChildItem -LiteralPath $testsRoot -Recurse -File -Filter "*.gd" |
        Where-Object { $_.BaseName -match '(?i)main.*flow|flow.*main' } |
        Select-Object -First 1

    if ($null -ne $mainFlowScene) {
        $relativePath = $mainFlowScene.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
        Invoke-ValidationStep "main flow" $godotExecutable @(
            "--headless",
            "--path",
            $repoRoot,
            "--scene",
            ("res://{0}" -f $relativePath)
        )
    } elseif ($null -ne $mainFlowScript) {
        $relativePath = $mainFlowScript.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
        Invoke-ValidationStep "main flow" $godotExecutable @(
            "--headless",
            "--path",
            $repoRoot,
            "--script",
            ("res://{0}" -f $relativePath)
        )
    } else {
        Write-Host "[SKIP] main flow test not found"
    }
} catch {
    Stop-Validation -StepName "validation runner" -ExitCode 1 -Message $_.Exception.Message
} finally {
    Pop-Location
}

Write-Host "VALIDATION_ALL_PASS"
