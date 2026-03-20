##
# cutil-gui.ps1
# Description: This script launches the graphical user interface for the cUtil command line tool.
# Example usage:
#      ./cutil-gui.ps1
##


$scriptBlock = {
    # Load the required assemblies for Windows Forms
    Add-Type -AssemblyName System.Windows.Forms

    # Create the main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "cUtil GUI"

    # set the size of the form to a ratio of the screen size, and make it resizable

    $width = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Size.Width;
    $height = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Size.Height;

    $width = $width / 2
    $height = $height / 2

    $form.Size = New-Object System.Drawing.Size($width, $height)
    $form.FormBorderStyle = "Sizable"

    $form.StartPosition = "CenterScreen"

    # Create a label
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Welcome to the cUtil GUI!"
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Size = New-Object System.Drawing.Size(380, 20)

    $utilityScriptsPath = Join-Path -Path (Get-Location) -ChildPath "scripts"

    # write a test button to the form that performs a system beep when clicked to demonstrate functionality
    $button = CreateButton -Text "Test Button" -X 10 -Y 40 -OnClick { 
        [console]::beep(500, 500)
        Write-Host "Test button clicked!" -ForegroundColor Green
    }
    $form.Controls.Add($button)

    # gather all available scripts into an array
    $availableScripts = Get-ChildItem -Path $utilityScriptsPath -Filter "*.ps1" | ForEach-Object { $_.BaseName }

    # for each script, create a corresponding button and store it in a buttons array
    $buttons = @()
    $y = 80
    $x = 10
    $i = 0
    foreach ($script in $availableScripts) {

        if ($i -gt 5) {
            $x += 210
            $y = 80
            $i = 0
        }

        $button = New-Object System.Windows.Forms.Button
        $button.Text = $script
        $button.Location = New-Object System.Drawing.Point($x, $y)
        $button.Size = New-Object System.Drawing.Size(200, 30)
        $button.Add_Click({ 
            Write-Host "Executing script: $script" -ForegroundColor Green
            # start a new job to run the script in a separate thread so that the GUI doesn't freeze while the script is running
            # pass the script name as an argument to the new job so that it knows which script to execute
            Start-Job -ScriptBlock {
                param($scriptName)
                param($scriptPath)
                $scriptPath = Join-Path -Path $scriptPath -ChildPath "$scriptName.ps1"
                # use start-process to run the script in a new PowerShell window so that the output is visible to the user, and pass the script name as an argument
                Start-Process powershell.exe -Command $scriptPath
                
            } -ArgumentList $script, $utilityScriptsPath

             # for testing purposes, also write the button text to the console to verify that the correct script is being executed when the button is clicked
             Write-Host "Button Text: " $button.Text -ForegroundColor Green

        })
        $buttons += $button

        $y += 40
        $i += 1
    }

    write-host "Buttons: ", $buttons

    foreach ($button in $buttons) {
        Write-Host "Button for script $($button.Text) created." -ForegroundColor Green
        $form.Controls.Add($button)
    }


    # Add the label to the form
    $form.Controls.Add($label)

    # Show the form
    $form.ShowDialog() # pauses execution of the script until the form is closed
}


# use start-job to run the GUI in a separate thread so that it doesn't block the main cUtil script from running in the console
Start-Job -ScriptBlock $scriptBlock
