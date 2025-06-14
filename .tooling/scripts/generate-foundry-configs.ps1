# Generate Azure AI Foundry agent configuration files
# Copies all existing agent YAML definitions into the .tooling/agents folder for Foundry

$sourceDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\..\bmad-agent\personas"
$destDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\agents"

Write-Host "Generating Foundry config files..."

Get-ChildItem -Path $sourceDir -Filter "*.agent.yaml" | ForEach-Object {
    $destFile = Join-Path $destDir $_.Name
    Copy-Item -Path $_.FullName -Destination $destFile -Force
    Write-Host "Copied $($_.Name) to .tooling/agents"
}

Write-Host "Generation complete. Review .tooling/agents for Foundry-compatible configs."
