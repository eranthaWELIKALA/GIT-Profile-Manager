Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Git Profile Manager'
$form.Width = 400
$form.Height = 300

$label1 = New-Object System.Windows.Forms.Label
$label1.Text = 'Git User Name:'
$label1.Top = 20
$label1.Left = 20
$form.Controls.Add($label1)

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Top = 20
$textBox1.Left = 150
$textBox1.Width = 210
$form.Controls.Add($textBox1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Text = 'Email:'
$label2.Top = 60
$label2.Left = 20
$form.Controls.Add($label2)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Top = 60
$textBox2.Left = 150
$textBox2.Width = 210
$form.Controls.Add($textBox2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Text = 'Identifiable Name:'
$label3.Top = 100
$label3.Left = 20
$form.Controls.Add($label3)

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Top = 100
$textBox3.Left = 150
$textBox3.Width = 210
$form.Controls.Add($textBox3)

$button = New-Object System.Windows.Forms.Button
$button.Text = 'Submit'
$button.Top = 140
$button.Left = 150
$button.Add_Click({
    $gitUserName = $textBox1.Text
    $email = $textBox2.Text
    $name = $textBox3.Text

    $command = "cmd.exe /c E:\Erantha\Personal\MyProjects\WindowsGitProfileManager\git-profile-gui-script.bat"
    $command += " " + $gitUserName
    $command += " " + $email
    $command += " " + $name

    Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/c $command"
    # Function to execute a command and capture its output
    function Execute-Command {
        param (
            [string]$command
        )

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo.FileName = "cmd.exe"
        $process.StartInfo.Arguments = "/c $command"
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.CreateNoWindow = $true
        $process.Start() | Out-Null

        $output = $process.StandardOutput.ReadToEnd()
        $error = $process.StandardError.ReadToEnd()

        $process.WaitForExit()

        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            Output   = $output
            Error    = $error
        }
    }

    # Run the command and capture the output
    $result = Execute-Command -command $command

    # Display the command output
    if ($result.ExitCode -eq 0) {
        Write-Output "Command executed successfully."
        Write-Output "Output:"
        Write-Output $result.Output
    } else {
        Write-Output "Command failed with exit code $($result.ExitCode)."
        Write-Output "Error:"
        Write-Output $result.Error
    }

    # Continue with other script logic
    $form.Close()
})
$form.Controls.Add($button)

$form.ShowDialog()
