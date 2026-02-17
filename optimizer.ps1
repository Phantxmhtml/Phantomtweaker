# Simple & Stable PC Optimizer
# Safe for irm | iex execution

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Phantom PC Optimizer"
$form.Size = New-Object System.Drawing.Size(500,400)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#1e1e1e"
$form.ForeColor = "White"

$status = New-Object System.Windows.Forms.Label
$status.Size = New-Object System.Drawing.Size(450,30)
$status.Location = New-Object System.Drawing.Point(25,320)
$status.Text = "Status: Waiting..."
$form.Controls.Add($status)

function Update-Status($msg) {
    $status.Text = "Status: $msg"
    $form.Refresh()
}

# Clean Temp Files
$btnTemp = New-Object System.Windows.Forms.Button
$btnTemp.Text = "Clean Temp Files"
$btnTemp.Size = New-Object System.Drawing.Size(200,40)
$btnTemp.Location = New-Object System.Drawing.Point(150,40)
$btnTemp.Add_Click({
    Update-Status "Cleaning temp files..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Update-Status "Temp cleaned!"
})
$form.Controls.Add($btnTemp)

# Enable High Performance
$btnPower = New-Object System.Windows.Forms.Button
$btnPower.Text = "Enable High Performance"
$btnPower.Size = New-Object System.Drawing.Size(200,40)
$btnPower.Location = New-Object System.Drawing.Point(150,100)
$btnPower.Add_Click({
    Update-Status "Enabling High Performance..."
    powercfg -setactive SCHEME_MIN
    Update-Status "High Performance Enabled!"
})
$form.Controls.Add($btnPower)

# Optimize Visual Effects
$btnVisual = New-Object System.Windows.Forms.Button
$btnVisual.Text = "Optimize Visual Effects"
$btnVisual.Size = New-Object System.Drawing.Size(200,40)
$btnVisual.Location = New-Object System.Drawing.Point(150,160)
$btnVisual.Add_Click({
    Update-Status "Optimizing visuals..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Value 2 -ErrorAction SilentlyContinue
    Update-Status "Visuals optimized!"
})
$form.Controls.Add($btnVisual)

# Flush DNS
$btnDNS = New-Object System.Windows.Forms.Button
$btnDNS.Text = "Flush DNS"
$btnDNS.Size = New-Object System.Drawing.Size(200,40)
$btnDNS.Location = New-Object System.Drawing.Point(150,220)
$btnDNS.Add_Click({
    Update-Status "Flushing DNS..."
    ipconfig /flushdns | Out-Null
    Update-Status "DNS flushed!"
})
$form.Controls.Add($btnDNS)

$form.ShowDialog()
