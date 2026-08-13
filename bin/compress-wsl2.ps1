# WSL2 Disk Image Compression Script (Integrated)
# Frees up unused space inside WSL, then compresses VHDX files

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges." -ForegroundColor Yellow
    Write-Host "Restarting with administrator privileges..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -Wait
    exit
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL2 Disk Image Compression Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Free up unused space inside WSL
Write-Host "`n[Step 1] Freeing up unused space inside WSL..." -ForegroundColor Cyan

# Get list of WSL distributions
$distributions = wsl --list --quiet 2>$null | Where-Object { $_ -and $_ -ne "NAME" }

if ($distributions) {
    foreach ($dist in $distributions) {
        if ([string]::IsNullOrWhiteSpace($dist)) {
            continue
        }
        
        Write-Host "`nProcessing: $dist" -ForegroundColor Yellow
        
        # Clean up unused space in WSL
        Write-Host "  Cleaning package cache..." -ForegroundColor Gray
        wsl -d $dist sudo apt-get clean -y 2>&1 | Out-Null
        
        Write-Host "  Removing temporary files..." -ForegroundColor Gray
        wsl -d $dist sudo rm -rf /tmp/* 2>&1 | Out-Null
        
        Write-Host "  Creating zero file to free unused space..." -ForegroundColor Gray
        Write-Host "  (This may take several minutes)" -ForegroundColor Gray
        
        # Create zero file to mark unused space
        wsl -d $dist bash -c "sudo dd if=/dev/zero of=/tmp/zero bs=1M 2>/dev/null; sudo rm -f /tmp/zero" 2>&1 | Out-Null
        
        Write-Host "  [OK] Completed processing $dist" -ForegroundColor Green
    }
} else {
    Write-Host "No WSL distributions found. Skipping..." -ForegroundColor Yellow
}

# Step 2: Shut down WSL completely
Write-Host "`n[Step 2] Shutting down WSL..." -ForegroundColor Cyan
wsl --shutdown 2>$null
Start-Sleep -Seconds 3
Write-Host "[OK] WSL shutdown completed" -ForegroundColor Green

# Step 3: Search for VHDX files
Write-Host "`n[Step 3] Searching for WSL2 VHDX files..." -ForegroundColor Cyan

$vhdxFiles = @()

# Common WSL2 VHDX file paths
$searchPaths = @(
    "$env:LOCALAPPDATA\Packages\*\LocalState\ext4.vhdx",
    "$env:USERPROFILE\AppData\Local\Packages\*\LocalState\ext4.vhdx",
    "$env:LOCALAPPDATA\wsl\*\ext4.vhdx",
    "$env:LOCALAPPDATA\Docker\wsl\*\ext4.vhdx"
)

foreach ($pattern in $searchPaths) {
    $found = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
    if ($found) {
        foreach ($file in $found) {
            if ($vhdxFiles -notcontains $file) {
                $vhdxFiles += $file
                Write-Host "  Found: $($file.FullName)" -ForegroundColor Green
            }
        }
    }
}

if ($vhdxFiles.Count -eq 0) {
    Write-Host "`n[ERROR] No VHDX files found." -ForegroundColor Red
    Write-Host "Please specify the VHDX file path manually." -ForegroundColor Yellow
    exit 1
}

# Step 4: Compress VHDX files
Write-Host "`n[Step 4] Compressing VHDX files..." -ForegroundColor Cyan

foreach ($vhdxFile in $vhdxFiles) {
    $filePath = $vhdxFile.FullName
    $fileSizeBefore = (Get-Item $filePath).Length / 1GB
    
    Write-Host "`n----------------------------------------" -ForegroundColor Cyan
    Write-Host "Target: $filePath" -ForegroundColor Cyan
    Write-Host "Size before: $([math]::Round($fileSizeBefore, 2)) GB" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    
    # Try Optimize-VHD first (more effective)
    $useOptimizeVHD = $false
    try {
        $optimizeCmd = Get-Command Optimize-VHD -ErrorAction SilentlyContinue
        if ($optimizeCmd) {
            $useOptimizeVHD = $true
        }
    } catch {
        $useOptimizeVHD = $false
    }
    
    if ($useOptimizeVHD) {
        Write-Host "`nCompressing using Optimize-VHD (recommended method)..." -ForegroundColor Yellow
        Write-Host "(This may take several minutes to hours)" -ForegroundColor Gray
        Write-Host "(Note: Administrator privileges may be required)" -ForegroundColor Gray
        
        $optimizeSuccess = $false
        try {
            $errorActionPreference = "Stop"
            Optimize-VHD -Path $filePath -Mode Full -ErrorAction Stop
            $optimizeSuccess = $true
        } catch {
            Write-Host "`n[WARNING] Optimize-VHD failed: $_" -ForegroundColor Yellow
            Write-Host "Switching to diskpart method..." -ForegroundColor Yellow
            $useOptimizeVHD = $false
        }
        
        if ($optimizeSuccess) {
            $fileSizeAfter = (Get-Item $filePath).Length / 1GB
            $saved = $fileSizeBefore - $fileSizeAfter
            
            Write-Host "`n[OK] Compression completed!" -ForegroundColor Green
            Write-Host "  Size after: $([math]::Round($fileSizeAfter, 2)) GB" -ForegroundColor Green
            Write-Host "  Space saved: $([math]::Round($saved, 2)) GB" -ForegroundColor Green
        }
    }
    
    if (-not $useOptimizeVHD) {
        # Fallback to diskpart method
        Write-Host "`nCompressing using diskpart..." -ForegroundColor Yellow
        Write-Host "(This may take several minutes to hours)" -ForegroundColor Gray
        
        # Create diskpart script
        $scriptPath = Join-Path $env:TEMP "wsl_compact_script.txt"
        
        $diskpartCommands = @(
            "select vdisk file=`"$filePath`"",
            "attach vdisk readonly",
            "compact vdisk",
            "detach vdisk"
        )
        
        # Use the system ANSI code page (not ASCII/UTF-8/Unicode) so diskpart can
        # correctly parse non-ASCII characters (e.g. Japanese) in the file path.
        $diskpartCommands | Out-File -FilePath $scriptPath -Encoding Default
        
        try {
            $result = & diskpart /s $scriptPath 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                $fileSizeAfter = (Get-Item $filePath).Length / 1GB
                $saved = $fileSizeBefore - $fileSizeAfter
                
                Write-Host "`n[OK] Compression completed!" -ForegroundColor Green
                Write-Host "  Size after: $([math]::Round($fileSizeAfter, 2)) GB" -ForegroundColor Green
                Write-Host "  Space saved: $([math]::Round($saved, 2)) GB" -ForegroundColor Green
            } else {
                Write-Host "`n[ERROR] Error during compression:" -ForegroundColor Red
                Write-Host $result -ForegroundColor Red
            }
        } catch {
            Write-Host "`n[ERROR] An error occurred: $_" -ForegroundColor Red
        } finally {
            # Clean up temporary file
            if (Test-Path $scriptPath) {
                Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "All operations completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
