# Link every skill in ~/.agents/skills into the Claude Code and Codex skill folders as junctions.
# Safe to run repeatedly. Never touches real folders or links that point somewhere else.

$ErrorActionPreference = 'Stop'

$source = Join-Path $env:USERPROFILE '.agents\skills'
$targets = @(
    (Join-Path $env:USERPROFILE '.claude\skills'),
    (Join-Path $env:USERPROFILE '.codex\skills')
)

$skills = Get-ChildItem -LiteralPath $source -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') }

foreach ($target in $targets) {
    if (-not (Test-Path -LiteralPath $target)) {
        New-Item -ItemType Directory -Path $target | Out-Null
    }

    foreach ($skill in $skills) {
        $link = Join-Path $target $skill.Name
        # Get-Item instead of Test-Path so broken junctions are detected too.
        $existing = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue

        if (-not $existing) {
            New-Item -ItemType Junction -Path $link -Target $skill.FullName | Out-Null
            Write-Host "linked  $link"
        }
        elseif ($existing.LinkType -eq 'Junction' -and @($existing.Target)[0] -eq $skill.FullName) {
            Write-Host "ok      $link"
        }
        else {
            Write-Warning "skipped $link (real folder or link to another place)"
        }
    }

    Get-ChildItem -LiteralPath $target -Directory -Force |
        Where-Object { $_.LinkType -eq 'Junction' -and -not (Test-Path -LiteralPath @($_.Target)[0]) } |
        ForEach-Object { Write-Warning "broken  $($_.FullName) -> $(@($_.Target)[0])" }
}
