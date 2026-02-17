# ==============================
# Phantom Performance Suite v2
# Gaming + Utility + Safe Tweaks
# ==============================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Phantom Performance Suite v2"
$form.Size = New-Object System.Drawing.Size(900,600)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(20,20,20)
$form.ForeColor = "White"

$fontTitle = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$fontNormal = New-Object System.Drawing.Font("Segoe UI",9)

# Title
$title = New-Object System.Windows.Forms.Label
$title.Text = "PHANTOM PERFORMANCE SUITE"
$title.Font = $fontTitle
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(250,15)
$form.Controls.Add($title)

# Tabs
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Size = New-Object System.Drawing.Size(860,470)
$tabs.Location = New-Object System.Drawing.Point(15,60)
$tabs.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)

$tabGaming = New-Object System.Windows.Forms.TabPage
$tabGaming.Text = "Gaming"

$tabCleanup = New-Object System.Windows.Forms.TabPage
$tabCleanup.Text = "Cleanup"

$tabPerformance = New-Object System.Windows.Forms.TabPage
$tabPerformance.Text = "Performance"

$tabSystem = New-Object System.Windows.Forms.TabPage
$tabSystem.Text = "System Monitor"

$tabs.Controls.AddRange(@($tabGaming,$tabCleanup,$tabPerformance,$tabSystem))
$form.Controls.Add($tabs)

# Status Bar
$status = New-Object System.Windows.Forms.Label
$status.Size = New-Object System.Drawing.Size(800,25)
$status.Location = New-Object System.Drawing.Point(30,535)
$status.Text = "Status: Ready"
$form.Controls.Add($status)

function Update-Status($msg){
    $status.Text = "Status: $msg"
    $form.Refresh()
}

function Add-Button($parent,$text,$x,$y,$action){
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(300,40)
    $btn.Location = New-Object System.Drawing.Point($x,$y)
    $btn.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
    $btn.ForeColor = "White"
    $btn.FlatStyle = "Flat"
    $btn.Add_Click($action)
    $parent.Controls.Add($btn)
}

# ---------------- Gaming ----------------

Add-Button $tabGaming "Enable Ultimate Performance" 50 40 {
    Update-Status "Activating Ultimate Performance..."
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    Update-Status "Ultimate Performance Enabled"
}

Add-Button $tabGaming "Optimize Visuals For Gaming" 50 100 {
    Update-Status "Optimizing visuals..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name VisualFXSetting -Value 2 -ErrorAction SilentlyContinue
    Update-Status "Visuals Optimized"
}

Add-Button $tabGaming "Open Startup Manager" 50 160 {
    Start-Process "taskmgr.exe"
}

Add-Button $tabGaming "Toggle Game Mode Settings" 50 220 {
    Start-Process "ms-settings:gaming-gamemode"
}

# ---------------- Cleanup ----------------

Add-Button $tabCleanup "Deep Temp Clean" 50 40 {
    Update-Status "Cleaning temp..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Update-Status "Temp Cleaned"
}

Add-Button $tabCleanup "Clear Prefetch" 50 100 {
    Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
    Update-Status "Prefetch Cleared"
}

Add-Button $tabCleanup "Flush DNS Cache" 50 160 {
    ipconfig /flushdns | Out-Null
    Update-Status "DNS Flushed"
}

# ---------------- Performance ----------------

Add-Button $tabPerformance "Disable Transparency" 50 40 {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name EnableTransparency -Value 0 -ErrorAction SilentlyContinue
    Update-Status "Transparency Disabled"
}

Add-Button $tabPerformance "Processor Scheduling: Programs" 50 100 {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" `
    -Name Win32PrioritySeparation -Value 26 -ErrorAction SilentlyContinue
    Update-Status "Processor Scheduling Optimized"
}

Add-Button $tabPerformance "Open Background Apps Settings" 50 160 {
    Start-Process "ms-settings:privacy-backgroundapps"
}

# ---------------- System Monitor ----------------

$sysInfo = New-Object System.Windows.Forms.Label
$sysInfo.Size = New-Object System.Drawing.Size(700,200)
$sysInfo.Location = New-Object System.Drawing.Point(50,40)
$tabSystem.Controls.Add($sysInfo)

$cpuName = (Get-CimInstance Win32_Processor).Name
$totalRAM = [Math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB,2)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $ramUsage = (Get-Counter '\Memory\% Committed Bytes In Use').CounterSamples.CookedValue
    $sysInfo.Text = "CPU: $cpuName`nRAM: $totalRAM GB`nCPU Usage: $([math]::Round($cpuUsage,2)) %`nRAM Usage: $([math]::Round($ramUsage,2)) %"
})
$timer.Start()

$form.ShowDialog()
