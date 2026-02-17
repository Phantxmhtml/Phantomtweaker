Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Simple PC Optimizer"
$form.Size = New-Object System.Drawing.Size(400,300)
$form.StartPosition = "CenterScreen"

$btnTemp = New-Object System.Windows.Forms.Button
$btnTemp.Text = "Clean Temp Files"
$btnTemp.Size = New-Object System.Drawing.Size(150,40)
$btnTemp.Location = New-Object System.Drawing.Point(120,50)

$btnTemp.Add_Click({
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("Temp files cleaned!")
})

$form.Controls.Add($btnTemp)

$btnFlush = New-Object System.Windows.Forms.Button
$btnFlush.Text = "Flush DNS"
$btnFlush.Size = New-Object System.Drawing.Size(150,40)
$btnFlush.Location = New-Object System.Drawing.Point(120,120)

$btnFlush.Add_Click({
    ipconfig /flushdns
    [System.Windows.Forms.MessageBox]::Show("DNS flushed!")
})

$form.Controls.Add($btnFlush)

$form.ShowDialog()

