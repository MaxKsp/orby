[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (& git rev-parse --show-toplevel).Trim()
if (-not $repoRoot) { throw 'Not inside the source repository.' }
$pipelinePath = Join-Path $repoRoot 'scripts/ai-pipeline.ps1'
$pipelineText = Get-Content -LiteralPath $pipelinePath -Raw
$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($pipelinePath, [ref]$tokens, [ref]$errors)
if ($errors.Count -gt 0) { throw 'Pipeline must parse before controlled fix-loop tests run.' }

function Get-PipelineFunctionDefinition {
    param([string]$Name)
    $definition = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $Name }, $true)
    if (-not $definition) { throw "Pipeline function not found: $Name" }
    return $definition.Extent.Text
}

Invoke-Expression (Get-PipelineFunctionDefinition -Name 'Get-ValidationFailureGuidance')
Invoke-Expression (Get-PipelineFunctionDefinition -Name 'Get-ValidationRetryAction')
Invoke-Expression (Get-PipelineFunctionDefinition -Name 'Assert-FilesWithinAllowlist')

function Invoke-ControlledRetry {
    param($Failure, [string[]]$FilesChangedByCorrection)

    $attempts = 0
    $action = Get-ValidationRetryAction -ExitCode 1 -AttemptsUsed $attempts -MaximumAttempts 2 -FailedItems @($Failure)
    if ($action -ne 'retry') { throw 'Controlled validation failure did not enter retry.' }
    $attempts++
    $guidance = Get-ValidationFailureGuidance -FailedItems @($Failure)
    if ($guidance.testOnly -and @($FilesChangedByCorrection | Where-Object { -not $_.StartsWith('tests/') }).Count -gt 0) {
        throw 'Controlled test-only correction attempted to change production.'
    }
    $action = Get-ValidationRetryAction -ExitCode 0 -AttemptsUsed $attempts -MaximumAttempts 2 -FailedItems @()
    return [pscustomobject]@{ attempts = $attempts; action = $action }
}

$crossRealm = Get-ValidationFailureGuidance -FailedItems @([pscustomobject]@{ stdout = 'Values have same structure but are not reference-equal'; stderr = '' })
if (-not $crossRealm.testOnly -or ($crossRealm.lines -join ' ') -notmatch 'Array\.from') {
    throw 'Cross-realm failure was not classified as a test-only normalization fix.'
}
$crossRealmCycle = Invoke-ControlledRetry -Failure ([pscustomobject]@{ label = 'js-test-1'; stdout = 'Values have same structure but are not reference-equal'; stderr = '' }) -FilesChangedByCorrection @('tests/js/cross_realm_test.js')
if ($crossRealmCycle.attempts -ne 1 -or $crossRealmCycle.action -ne 'review') { throw 'Cross-realm failure was not corrected on the first controlled retry.' }

$floatingPoint = Get-ValidationFailureGuidance -FailedItems @([pscustomobject]@{ stdout = '1000.0000000000001 !== 1000'; stderr = '' })
if (-not $floatingPoint.testOnly -or ($floatingPoint.lines -join ' ') -notmatch '1e-9') {
    throw 'Floating-point failure was not classified as a test-only tolerance fix.'
}
$floatingPointCycle = Invoke-ControlledRetry -Failure ([pscustomobject]@{ label = 'js-test-1'; stdout = '1000.0000000000001 !== 1000'; stderr = '' }) -FilesChangedByCorrection @('tests/js/finance_period_calculation_test.js')
if ($floatingPointCycle.attempts -ne 1 -or $floatingPointCycle.action -ne 'review') { throw 'Floating-point failure was not corrected on the first controlled retry.' }

$phase = [pscustomobject]@{ allowedFiles = @('tests/js/allowed_test.js') }
Assert-FilesWithinAllowlist -Files @('tests/js/allowed_test.js') -PhaseObject $phase
# Represents ResumePhase accepting an existing diff that is already in scope.
Assert-FilesWithinAllowlist -Files @('tests/js/allowed_test.js') -PhaseObject $phase
$outsideRejected = $false
try {
    Assert-FilesWithinAllowlist -Files @('assets/app.js') -PhaseObject $phase
} catch {
    $outsideRejected = $true
}
if (-not $outsideRejected) { throw 'A file outside the allowlist was not rejected.' }

$failure = [pscustomobject]@{ label = 'js-test-1' }
if ((Get-ValidationRetryAction -ExitCode 1 -AttemptsUsed 0 -MaximumAttempts 2 -FailedItems @($failure)) -ne 'retry') { throw 'First failed validation should retry.' }
if ((Get-ValidationRetryAction -ExitCode 1 -AttemptsUsed 2 -MaximumAttempts 2 -FailedItems @($failure)) -ne 'stop') { throw 'MaxFixAttempts was not respected.' }
if ((Get-ValidationRetryAction -ExitCode 0 -AttemptsUsed 1 -MaximumAttempts 2 -FailedItems @()) -ne 'review') { throw 'Approved validation did not proceed to review.' }
$scopeFailure = [pscustomobject]@{ label = 'scope' }
if ((Get-ValidationRetryAction -ExitCode 1 -AttemptsUsed 0 -MaximumAttempts 2 -FailedItems @($scopeFailure)) -ne 'reject-scope') { throw 'Scope failure was not rejected immediately.' }

if ($pipelineText -notmatch '\[string\]\$ResumePhase' -or $pipelineText -notmatch 'ResumePhase starting validation') {
    throw 'ResumePhase with an existing diff is not wired into validation.'
}
if ($pipelineText -notmatch 'Test-only validation failure changed production files') {
    throw 'Test-only corrections do not protect production files.'
}
if ($pipelineText.IndexOf('Invoke-PhaseValidationAttempt') -gt $pipelineText.LastIndexOf('Invoke-CodexReview')) {
    throw 'Validation approval is not ordered before review.'
}

Write-Host 'Validation fix-loop controlled tests: OK'
