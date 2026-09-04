# =============================================================================
# AUTO-SYNC-WATCH.ps1  —  file-watcher based git auto-sync.
#
# Registers a .NET FileSystemWatcher on the repo folder. When any file changes
# (create/modify/delete/rename), starts a 60-second debounce timer. If more
# changes arrive during the debounce, the timer resets. When the timer fires
# with no fresh changes, runs the standard add + commit + push.
#
# Idle = zero disk activity, zero commits, zero pushes.
# Active editing = one commit per burst of activity.
#
# Runs as a Task Scheduler logon task — starts when the user signs in and
# runs forever until logoff. See INSTALL-AUTO-SYNC-WATCH.bat.
# =============================================================================

$ErrorActionPreference = 'Continue'
$RepoDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogPath  = Join-Path $RepoDir 'AUTO-SYNC.log'
$DebounceMs = 60000  # 60 seconds

Set-Location -LiteralPath $RepoDir

function Write-SyncLog([string]$msg) {
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -LiteralPath $LogPath -Value "[$ts] $msg" -Encoding UTF8
}

Write-SyncLog "=== AUTO-SYNC-WATCH started at $RepoDir ==="

if (-not (Test-Path (Join-Path $RepoDir '.git'))) {
    Write-SyncLog "[ERROR] no .git folder here — did INIT.bat run yet?"
    exit 1
}

# Debounce state
$script:pendingTimer = $null
$script:lastChange = [DateTime]::Now

# The actual sync work — runs when debounce fires
function Invoke-SyncNow {
    Write-SyncLog "sync fired (debounce elapsed)"
    Set-Location -LiteralPath $RepoDir

    # Any actual changes?
    $status = git status --porcelain 2>&1
    if (-not $status) {
        Write-SyncLog "  no changes to commit"
        return
    }

    $count = ($status | Measure-Object).Count
    Write-SyncLog "  $count file(s) changed; committing"

    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    git add . 2>&1 | Out-Null
    git commit -m "auto-sync $ts" 2>&1 | Add-Content -LiteralPath $LogPath -Encoding UTF8
    git push 2>&1 | Add-Content -LiteralPath $LogPath -Encoding UTF8
    Write-SyncLog "  push complete"
}

# Handler that resets the debounce on every file event
$onChange = {
    $script:lastChange = [DateTime]::Now
    # If a timer is already pending, restart it
    if ($script:pendingTimer) {
        $script:pendingTimer.Stop()
    }
    $script:pendingTimer = New-Object System.Timers.Timer
    $script:pendingTimer.Interval = $DebounceMs
    $script:pendingTimer.AutoReset = $false
    Register-ObjectEvent -InputObject $script:pendingTimer -EventName Elapsed -SourceIdentifier 'ChzSyncFire' -Action {
        try { Invoke-SyncNow } catch { Write-SyncLog "[ERR] $($_.Exception.Message)" }
        Unregister-Event -SourceIdentifier 'ChzSyncFire' -Force -ErrorAction SilentlyContinue
    } | Out-Null
    $script:pendingTimer.Start()
}

# Watch the repo folder recursively
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $RepoDir
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor `
                       [System.IO.NotifyFilters]::FileName    -bor `
                       [System.IO.NotifyFilters]::DirectoryName -bor `
                       [System.IO.NotifyFilters]::Size
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier 'ChzChanged' -Action $onChange | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier 'ChzCreated' -Action $onChange | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Deleted -SourceIdentifier 'ChzDeleted' -Action $onChange | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Renamed -SourceIdentifier 'ChzRenamed' -Action $onChange | Out-Null

Write-SyncLog "watching $RepoDir (debounce=$($DebounceMs)ms)"

# Keep the script alive
try {
    while ($true) { Start-Sleep -Seconds 60 }
} finally {
    Unregister-Event -SourceIdentifier 'ChzChanged' -Force -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier 'ChzCreated' -Force -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier 'ChzDeleted' -Force -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier 'ChzRenamed' -Force -ErrorAction SilentlyContinue
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-SyncLog "AUTO-SYNC-WATCH stopped"
}
