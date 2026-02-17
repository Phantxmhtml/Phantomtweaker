# ================================
# PHANTOM PERFORMANCE SUITE v3
# FAST • CLEAN • ASYNC
# ================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# -------------------------------
# ADMIN CHECK
# -------------------------------
If (-NOT ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    [System.Windows.Forms.MessageBox]::Show("Please run as Administrator.")
    exit
}

# -------------------------------
# ASYNC RUNSPACE FUNCTION
# -------------------------------
function Run-Async {
    param ($ScriptBlock)

    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $runspace
    $ps.AddScript($ScriptBlock) | Out-Null
    $ps.BeginInvoke()
}

# -------------------------------
# MAIN FORM
# -------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "PHANTOM PERFORMANCE SUITE v3"
$form.Size = New-Object System.Drawing.Size(900,600)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#111111"
$form.ForeColor = "White"

# -------------------------------
# STATUS BAR
# -------------------------------
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Status: Ready"
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(10,530)
$form.Controls.Add($statusLabel)

function Update-Status($text){
    $form.Invoke([action]{
        $statusLabel.Text = "Status: $text"
    })
}

# -------------------------------
# TABS
# -------------------------------
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Size = New-Object System.Drawing.Size(860,480)
$tabs.Location = New-Object System.Drawing.Point(10,10)
$tabs.Appearance = "Normal"

$form.Controls.Add($tabs)

function New-Tab($name){
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $name
    $tab.BackColor = "#1a1a1a"
    $tabs.Controls.Add($tab)
    return $tab
}

$tabGaming = New-Tab "Gaming"
$tabCleanup = New-Tab "Cleanup"
$tabPerformance = New-Tab "Performance"
$tabSystem = New-Tab "System"

# -------------------------------
# BUTTON CREATOR
# -------------------------------
function New-Button($parent,$text,$x,$y,$action){

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(250,40)
    $btn.Location = New-Object System.Drawing.Point($x,$y)
    $btn.BackColor = "#222222"
    $btn.FlatStyle = "Flat"
    $btn.ForeColor = "White"

    $btn.Add_Click({
        Update-Status "Running $text..."
        Run-Async $action
        Update-Status "Completed $text"
    })

    $parent.Controls.Add($btn)
}

# ================================
# GAMING TWEAKS
# ================================

New-Button $tabGaming "Enable Ultimate Performance" 40 40 {
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
}

New-Button $tabGaming "Disable Xbox Services" 40 100 {
    Stop-Service XblGameSave -Force -ErrorAction SilentlyContinue
    Stop-Service XboxNetApiSvc -Force -ErrorAction SilentlyContinue
}

New-Button $tabGaming "Disable Game DVR" 40 160 {
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
}

New-Button $tabGaming "Disable Fullscreen Optimizations" 40 220 {
    reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 2 /f
}

# ================================
# CLEANUP
# ================================

New-Button $tabCleanup "Clean Temp Files" 40 40 {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
}

New-Button $tabCleanup "Flush DNS" 40 100 {
    ipconfig /flushdns
}

New-Button $tabCleanup "Clear Prefetch" 40 160 {
    Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
}

New-Button $tabCleanup "Clear Recycle Bin" 40 220 {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

# ================================
# PERFORMANCE
# ================================

New-Button $tabPerformance "Disable SysMain" 40 40 {
    Stop-Service SysMain -Force -ErrorAction SilentlyContinue
    Set-Service SysMain -StartupType Disabled
}

New-Button $tabPerformance "Disable Windows Search" 40 100 {
    Stop-Service WSearch -Force -ErrorAction SilentlyContinue
    Set-Service WSearch -StartupType Disabled
}

New-Button $tabPerformance "Optimize Visual Effects" 40 160 {
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    /v VisualFXSetting /t REG_DWORD /d 2 /f
}

New-Button $tabPerformance "Disable Startup Delay" 40 220 {
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" `
    /v StartupDelayInMSec /t REG_DWORD /d 0 /f
}

# ================================
# SYSTEM INFO
# ================================

$sysInfo = New-Object System.Windows.Forms.Label
$sysInfo.AutoSize = $true
$sysInfo.Location = New-Object System.Drawing.Point(40,40)
$sysInfo.ForeColor = "White"

$cpu = (Get-CimInstance Win32_Processor).Name
$ram = [Math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory /1GB,2)
$gpu = (Get-CimInstance Win32_VideoController).Name

$sysInfo.Text = @"
CPU: $cpu
RAM: $ram GB
GPU: $gpu
"@

$tabSystem.Controls.Add($sysInfo)

# -------------------------------
# RUN APP
# -------------------------------
$form.ShowDialog()
