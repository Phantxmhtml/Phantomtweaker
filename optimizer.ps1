# Phantom Performance Suite
# Safe, Modern UI Optimizer

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Phantom Performance Suite"
$form.Size = New-Object System.Drawing.Size(650,500)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18,18,18)
$form.ForeColor = "White"

$fontTitle = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
$fontButton = New-Object System.Drawing.Font("Segoe UI",10)

$title = New-Object System.Windows.Forms.Label
$title.Text = "PHANTOM PERFORMANCE"
$title.Font = $fontTitle
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(150,20)
$form.Controls.Add($title)

$status = New-Object System.Windows.Forms.Label
$status.Size = New-Object System.Drawing.Size(600,30)
$status.Location = New-Object System.Drawing.Point(20,420)
$status.Text = "Status: Ready"
$form.Controls.Add($status)

function Update-Status($msg) {
    $status.Text = "Status: $msg"
    $form.Refresh()
}

function Styled-Button($text,$x,$y,$action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Font = $fontButton
    $btn.Size = New-Object System.Drawing.Size(250,45)
    $btn.Location = New-Object System.Drawing.Point($x,$y)
    $btn.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
    $btn.ForeColor = "White"
    $btn.FlatStyle = "Flat"
    $btn.Add_Click($action)
    $form.Controls.Add($btn)
}

# CLEAN TEMP
Styled-Button "Deep Clean Temp Files" 60 100 {
    Update-Status "Cleaning temp files..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Update-Status "Temp cleaned!"
}

# HIGH PERFORMANCE MODE
Styled-Button "Enable High Performance" 340 100 {
    Update-Status "Enabling high performance..."
    powercfg -setactive SCHEME_MIN
    Update-Status "High performance enabled!"
}

# ULTIMATE PERFORMANCE
Styled-Button "Enable Ultimate Performance" 60 170 {
    Update-Status "Activating ultimate performance..."
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    Update-Status "Ultimate performance enabled!"
}

# VISUAL OPTIMIZATION
Styled-Button "Optimize Visual Effects" 340 170 {
    Update-Status "Optimizing visuals..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name VisualFXSetting -Value 2 -ErrorAction SilentlyContinue
    Update-Status "Visual effects optimized!"
}

# FLUSH DNS
Styled-Button "Flush DNS Cache" 60 240 {
    Update-Status "Flushing DNS..."
    ipconfig /flushdns | Out-Null
    Update-Status "DNS flushed!"
}

# CLEAR PREFETCH
Styled-Button "Clear Prefetch Cache" 340 240 {
    Update-Status "Clearing prefetch..."
    Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
    Update-Status "Prefetch cleared!"
}

# DISABLE STARTUP APPS (opens manager)
Styled-Button "Open Startup Manager" 60 310 {
    Update-Status "Opening startup manager..."
    Start-Process "taskmgr.exe"
}

# SYSTEM INFO PANEL
$info = New-Object System.Windows.Forms.Label
$info.Size = New-Object System.Drawing.Size(600,60)
$info.Location = New-Object System.Drawing.Point(20,360)

$cpu = (Get-CimInstance Win32_Processor).Name
$ram = [Math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB,2)

$info.Text = "CPU: $cpu `nRAM: $ram GB"
$form.Controls.Add($info)

$form.ShowDialog()
