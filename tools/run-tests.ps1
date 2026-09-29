param(
    [Parameter(Mandatory = $true)]
    [string]$GodotPath
)

$ErrorActionPreference = 'Stop'
$taskEngine = (Resolve-Path -LiteralPath $GodotPath).Path
$taskProject = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskLogFolder = Join-Path $taskProject '.godot/test-logs'
New-Item -ItemType Directory -Path $taskLogFolder -Force | Out-Null

foreach ($taskTest in @('test_deal_round.gd', 'test_table_input.gd')) {
    $taskLogPath = Join-Path $taskLogFolder ($taskTest + '.log')
    & $taskEngine --headless --path $taskProject --script ('tests/' + $taskTest) --log-file $taskLogPath
    if ($LASTEXITCODE -ne 0) {
        throw "Failed: $taskTest (exit code $LASTEXITCODE)"
    }
    if (Select-String -LiteralPath $taskLogPath -Pattern 'SCRIPT ERROR|FAIL:|Parse Error' -Quiet) {
        throw "Script error in $taskTest. See $taskLogPath"
    }
}
Write-Output 'All card-dealing and input checks passed.'
