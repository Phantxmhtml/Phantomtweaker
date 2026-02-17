# Require Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] 
[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    [System.Windows.Forms.MessageBox]::Show("Please run PowerShell as Administrator!")
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Phantom Max Performance Optimizer"
$form.Size = New-Object System.Drawing.Size(500,450)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#121212"
$form.ForeColor = "White"

$status = New-Object System.Windows.Forms.Label
$status.Size = New-Object System.Drawing.Size(450,30)
$status.Location = New-Object System.Drawing.Point(25,360)
$status.Text = "Status: Waiting..."
$form.Controls.Add($status)

function Update-Status($msg) {
    $status.Text = "Status: $msg"
    $form.Refresh()
}

function Create-RestorePoint {
    Update-Status "Creating restore point..."
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Before Phantom Optimization" -RestorePointType "MODIFY_SETTINGS"
}

function Clean-TempFiles {
    Update-Status "Cleaning temp files..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

function Enable-UltimatePerformance {
    Update-Status "Enabling Ultimate Performance..."
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
}

function Optimize-VisualEffects {
    Update-Status "Optimizing visual effects..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name VisualFXSetting -Value 2
}

function Flush-DNS {
    Update-Status "Flushing DNS..."
    ipconfig /flushdns | Out-Null
}

# Buttons

$btnOptimize = New-Object System.Windows.Forms.Button
$btnOptimize.Text = "Run Full Optimization"
$btnOptimize.Size = New-Object System.Drawing.Size(250,50)
$btnOptimize.Location = New-Object System.Drawing.Point(125,60)
$btnOptimize.BackColor = "#1f6feb"
$btnOptimize.ForeColor = "White"

$btnOptimize.Add_Click({
    Create-RestorePoint
    Clean-TempFiles
    Enable-UltimatePerformance
    Optimize-VisualEffects
    Flush-DNS
    Update-Status "Optimization Complete!"
})

$form.Controls.Add($btnOptimize)

$form.ShowDialog()
