# ==========================================
# PHANTOM TWEAKER - BLACK EDITION v2
# Clean • Fast • No Lag
# ==========================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Admin Check
if (-not ([Security.Principal.WindowsPrincipal] `
[Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    [System.Windows.Forms.MessageBox]::Show("Run as Administrator.")
    exit
}

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PHANTOM TWEAKER"
$form.Size = New-Object System.Drawing.Size(750,550)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0f0f0f"
$form.ForeColor = "White"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Title
$title = New-Object System.Windows.Forms.Label
$title.Text = "PHANTOM PERFORMANCE PANEL"
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(180,20)
$form.Controls.Add($title)

# Status Label
$status = New-Object System.Windows.Forms.Label
$status.Text = "Status: Ready"
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(20,480)
$form.Controls.Add($status)

function Update-Status($text){
    $status.Text = "Status: $text"
}

# Button Style Function
function New-Button($text,$x,$y,$action){

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(300,40)
    $btn.Location = New-Object System.Drawing.Point($x,$y)
    $btn.BackColor = "#1c1c1c"
    $btn.ForeColor = "White"
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderColor = "#333333"

    $btn.Add_Click({
        Update-Status("Running $text...")
        try {
            & $action
            Update-Status("$text completed.")
        }
        catch {
            Update-Status("Error running $text")
        }
    })

    $form.Controls.Add($btn)
}

# ==========================================
# CLEANUP SECTION
# ==========================================

New-Button "Clean Temp Files" 50 100 {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
}

New-Button "Clear Prefetch" 50 150 {
    Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
}

New-Button "Flush DNS" 50 200 {
    ipconfig /flushdns | Out-Null
}

New-Button "Clear Recycle Bin" 50 250 {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

New-Button "Disk Cleanup (Silent)" 50 300 {
    cleanmgr /sagerun:1
}

# ==========================================
# PERFORMANCE SECTION
# ==========================================

New-Button "Enable Ultimate Performance" 380 100 {
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
}

New-Button "Disable SysMain" 380 150 {
    Stop-Service SysMain -Force -ErrorAction SilentlyContinue
    Set-Service SysMain -StartupType Disabled
}

New-Button "Disable Windows Search" 380 200 {
    Stop-Service WSearch -Force -ErrorAction SilentlyContinue
    Set-Service WSearch -StartupType Disabled
}

New-Button "Disable Startup Delay" 380 250 {
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" `
    /v StartupDelayInMSec /t REG_DWORD /d 0 /f | Out-Null
}

New-Button "Optimize Visual Effects" 380 300 {
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    /v VisualFXSetting /t REG_DWORD /d 2 /f | Out-Null
}

# ==========================================
# GAMING SECTION
# ==========================================

New-Button "Disable Xbox Services" 50 350 {
    Stop-Service XblGameSave -Force -ErrorAction SilentlyContinue
    Stop-Service XboxNetApiSvc -Force -ErrorAction SilentlyContinue
}

New-Button "Disable Game DVR" 50 400 {
    reg add "HKCU\System\GameConfigStore" `
    /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
}

New-Button "Disable Fullscreen Optimizations" 380 350 {
    reg add "HKCU\System\GameConfigStore" `
    /v GameDVR_FSEBehavior /t REG_DWORD /d 2 /f | Out-Null
}

New-Button "Network Boost (TCP Optimize)" 380 400 {
    netsh int tcp set global autotuninglevel=normal | Out-Null
}

# ==========================================
# SYSTEM SECTION
# ==========================================

New-Button "Create Restore Point" 50 450 {
    Enable-ComputerRestore -Drive "C:\"
    Checkpoint-Computer -Description "Phantom Restore Point"
}

New-Button "Restart Explorer" 380 450 {
    Stop-Process -Name explorer -Force
    Start-Process explorer
}

$form.ShowDialog()
