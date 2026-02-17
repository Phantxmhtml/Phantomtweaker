# ==================================================
# PHANTOM TWEAKER - STABLE BLACK EDITION
# Fast • Clean • Safe • No Random Errors
# ==================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---------------- ADMIN CHECK ----------------
if (-not ([Security.Principal.WindowsPrincipal] `
[Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    [System.Windows.Forms.MessageBox]::Show("Please run as Administrator.")
    exit
}

# ---------------- MAIN FORM ----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "PHANTOM TWEAKER"
$form.Size = New-Object System.Drawing.Size(800,600)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0f0f0f"
$form.ForeColor = "White"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Title
$title = New-Object System.Windows.Forms.Label
$title.Text = "PHANTOM PERFORMANCE PANEL"
$title.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(170,20)
$form.Controls.Add($title)

# Status Label
$status = New-Object System.Windows.Forms.Label
$status.Text = "Status: Ready"
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(20,520)
$form.Controls.Add($status)

function Update-Status($msg){
    $status.Text = "Status: $msg"
}

# ---------------- SAFE EXECUTION ----------------
function Run-Safely($scriptBlock){

    try {
        $ErrorActionPreference = "Stop"
        & $scriptBlock
        Update-Status "Completed successfully."
    }
    catch {
        Update-Status $_.Exception.Message
    }
    finally {
        $ErrorActionPreference = "Continue"
    }
}

# ---------------- BUTTON CREATOR ----------------
function New-Button($text,$x,$y,$scriptBlock){

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(330,40)
    $btn.Location = New-Object System.Drawing.Point($x,$y)
    $btn.BackColor = "#1c1c1c"
    $btn.ForeColor = "White"
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderColor = "#333333"

    $btn.Add_Click({
        Update-Status "Running $text..."
        Run-Safely $scriptBlock
    })

    $form.Controls.Add($btn)
}

# ==================================================
# CLEANUP TOOLS
# ==================================================

New-Button "Clean Temp Files" 40 100 {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
}

New-Button "Clear Prefetch" 40 150 {
    if (Test-Path "C:\Windows\Prefetch") {
        Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

New-Button "Flush DNS" 40 200 {
    ipconfig /flushdns | Out-Null
}

New-Button "Clear Recycle Bin" 40 250 {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

New-Button "Disk Cleanup (Silent)" 40 300 {
    cleanmgr /verylowdisk | Out-Null
}

# ==================================================
# PERFORMANCE
# ==================================================

New-Button "Enable Ultimate Performance" 420 100 {
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
}

New-Button "Disable SysMain" 420 150 {
    if (Get-Service SysMain -ErrorAction SilentlyContinue) {
        Stop-Service SysMain -Force -ErrorAction SilentlyContinue
        Set-Service SysMain -StartupType Disabled
    }
}

New-Button "Disable Windows Search" 420 200 {
    if (Get-Service WSearch -ErrorAction SilentlyContinue) {
        Stop-Service WSearch -Force -ErrorAction SilentlyContinue
        Set-Service WSearch -StartupType Disabled
    }
}

New-Button "Disable Startup Delay" 420 250 {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "Serialize" -Force | Out-Null

    Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" `
    -Name "StartupDelayInMSec" -Value 0 -Type DWord
}

New-Button "Optimize Visual Effects" 420 300 {
    Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name "VisualFXSetting" -Value 2 -Type DWord -ErrorAction SilentlyContinue
}

# ==================================================
# GAMING
# ==================================================

New-Button "Disable Xbox Services" 40 360 {
    $services = "XblGameSave","XboxNetApiSvc","XboxGipSvc"
    foreach ($svc in $services){
        if (Get-Service $svc -ErrorAction SilentlyContinue){
            Stop-Service $svc -Force -ErrorAction SilentlyContinue
            Set-Service $svc -StartupType Disabled
        }
    }
}

New-Button "Disable Game DVR" 40 410 {
    Set-ItemProperty `
    -Path "HKCU:\System\GameConfigStore" `
    -Name "GameDVR_Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

New-Button "Network Optimization" 420 360 {
    netsh int tcp set global autotuninglevel=normal | Out-Null
    netsh int tcp set global rss=enabled | Out-Null
}

New-Button "Restart Explorer" 420 410 {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer
}

# ==================================================
# SYSTEM UTILITIES
# ==================================================

New-Button "Create Restore Point" 40 460 {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Phantom Restore Point" -ErrorAction SilentlyContinue
}

New-Button "Open Services Manager" 420 460 {
    Start-Process services.msc
}

$form.ShowDialog()
