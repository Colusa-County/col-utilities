#include "ScriptCommand.h"

ScriptCommand::ScriptCommand()
{
    Initialize();
}

ScriptCommand::~ScriptCommand()
{

}

void ScriptCommand::Initialize()
{
    // Do other initialize stuff here if needed in the future
 
    CommandReturn = "All good!";
    RenderMenu();
}

/**
* Can consolidate menu functions into one menu render function
* Need to aggregate menu data into a data structure to do this effectively
*  - Menu name
*  - Menu options + their descriptions
*  - etc?
*/
void ScriptCommand::RenderMenu()
{
    string user_input = "";
    while (MenuActive)
    {
        cout << "Status: " + CommandReturn << endl << endl;
        cout << "._____________________________________________________." << endl;
        cout << "| Script Command - Main Menu                          |" << endl;
        cout << "|                                                     |" << endl;
        cout << "| 1. Software/Apps Uninstall/Install                  |" << endl;
        cout << "| 2. Data Backup/Restore                              |" << endl;
        cout << "|-----------------------------------------------------|" << endl;
        cout << "| >> ";
        cin >> user_input;
        ClearScreen();
        ParseMenuInput(user_input);
    }
}

void ScriptCommand::RenderSoftwareMenu()
{
    string user_input = "";
    bool CurrentMenuActive = true;
    while (CurrentMenuActive)
    {
        cout << "Status: " + CommandReturn << endl;
        cout << "._____________________________________________________." << endl;
        cout << "| Script Command - App Install/Uninstall Menu  (Admin)|" << endl;
        cout << "|                                                     |" << endl;
        cout << "| 0. Uninstall Outlook(new) for all users             | " << endl;
        cout << "| 3. Uninstall MS app for all users                   |" << endl;
        cout << "|_____________________________________________________|" << endl;
        cout << "|>> ";
        cin >> user_input;
        if (user_input == "b")
        {
            CurrentMenuActive = false;
            ClearScreen();
        }
        else
        {
            ParseInput(user_input);
            ClearScreen();
        }
    }
}

void ScriptCommand::RenderDataBackupMenu()
{
    string user_input = "";
    bool CurrentMenuActive = true;
    while (CurrentMenuActive)
    {
        cout << "Status: " + CommandReturn << endl;
        cout << "._____________________________________________________." << endl;
        cout << "| Script Command - Data Backup/Restore Menu    (Admin)|" << endl;
        cout << "|                                                     |" << endl;
        cout << "| 1. Backup user data to U drive                      | " << endl;
        cout << "| 2. Restore user data from U drive                   |" << endl;
        cout << "|_____________________________________________________|" << endl;
        cout << "|>> ";
        cin >> user_input;
        if (user_input == "b")
        {
            CurrentMenuActive = false;
            ClearScreen();
        }
        else
        {
            ParseInput(user_input);
            ClearScreen();
        }
    }
}

void ScriptCommand::ListInstalledApps()
{
    system("powershell Select-Object DisplayName, PackageName | powershell Get-AppxProvisionedPackage -Online >> C:\\applist.txt && explorer C:\\applist.txt");
}

void ScriptCommand::ParseMenuInput(string Input)
{
    int Selection = SanitizeInput(Input);
    if (Selection == Menu.SoftwareMenu)
    {
        ClearScreen();
        RenderSoftwareMenu();
    }
    else if (Selection == Menu.BackupRestoreMenu)
    {
        ClearScreen();
        RenderDataBackupMenu();
    }
}

int ScriptCommand::SanitizeInput(string Input)
{
    if (Input == "") return -1;
    if (Input == "exit") exit(0);
    for (int i = 0; i < Input.size(); i++)
    {
        if (!isdigit(Input[i])) return -1;
    }
    return stoi(Input);
}

void ScriptCommand::ParseInput(string Input)
{
    if (Input == "list")
    {
        ListInstalledApps();
    }

    int Selection = SanitizeInput(Input);

    if (Selection == Scripts.Backup)
    {
        SetExecutionPolicy(Policy.RemoteSigned);
        BackupScript();
        SetExecutionPolicy(Policy.Restricted);
    }
    else if (Selection == Scripts.Restore)
    {
        SetExecutionPolicy(Policy.RemoteSigned);
        RestoreScript();
        SetExecutionPolicy(Policy.Restricted);
    }
    else if (Selection == Scripts.UninstallOneApp)
    {
        SetExecutionPolicy(Policy.RemoteSignedAdmin);
        UninstallMSAppScript();
        SetExecutionPolicy(Policy.RestrictedAdmin);
    }
    else if (Selection == Scripts.InstallOneApp)
    {
        SetExecutionPolicy(Policy.RemoteSignedAdmin);
        InstallMSAppScript();
        SetExecutionPolicy(Policy.RestrictedAdmin);
    }
    else if (Selection == Scripts.UninstallOutlookNew)
    {
        SetExecutionPolicy(Policy.RemoteSignedAdmin);
        UninstallOutlookNew();
        SetExecutionPolicy(Policy.RestrictedAdmin);
    }
    else if (Selection == 1234567890)
    {
        SetExecutionPolicy(Policy.RemoteSigned);
        system("powershell ./scripts/testing.ps1");
        SetExecutionPolicy(Policy.Restricted);
    }
}

void ScriptCommand::ClearScreen()
{
    for (int i = 0; i < 100; i++)
    {
        cout << endl;
    }
}

void ScriptCommand::UninstallOutlookNew()
{
    string cmd = "powershell Remove-AppxPackage -AllUsers $(Get-AppxPackage -AllUsers -Name Microsoft.OutlookForWindows)";
    cout << "Uninstalling Outlook(new) MS app..." << endl;
    system(cmd.c_str());
    cout << "Done!" << endl;
    CommandReturn = "Done! Uninstalled Outlook(new)";
}

void ScriptCommand::UninstallMSAppScript()
{
    string AppName = "";
    string UninstallMSAppScriptCommand = "";
    bool Uninstalling = true;
    while (Uninstalling)
    {
        cout << "q to quit" << endl;
        cout << "App Name: ";
        cin >> AppName;
        if (AppName == "q")
        {
            Uninstalling = false;
            return;
        }
        else if (AppName == "list")
        {
            ListInstalledApps();
        }
        else
        {
            UninstallMSAppScriptCommand = "powershell Remove-AppxPackage -AllUsers $(Get-AppxPackage -AllUsers -Name " + AppName + ")";
            cout << "Uninstalling ..." << endl;
            system(UninstallMSAppScriptCommand.c_str());
            cout << "Done." << endl;
            cout << endl;
            CommandReturn = "Done! Uninstalled " + AppName;
        }
    }
}

void ScriptCommand::InstallMSAppScript()
{

}

void ScriptCommand::DefaultUninstallApps()
{
    string Apps = "Microsoft.OutlookForWindows Microsoft.Xbox.TCUI Microsoft.XboxGamingOverlap Microsoft.XboxIdentityProvider Microsoft.XboxSpeechToTextOverlay Microsoft.ZuneMusic";
}

void ScriptCommand::BackupScript()
{
    CommandReturn = "PC backup complete";
    system("powershell ./scripts/backup.ps1");
}

void ScriptCommand::RestoreScript()
{
    CommandReturn = "PC restore complete";
    system("powershell ./scripts/restore.ps1");
}

void ScriptCommand::BgInfoInstallScript()
{
    CommandReturn = "BgInfo has been installed";
    system("powershell ./scripts/install-bginfo.ps1");
}

void ScriptCommand::SetExecutionPolicy(int PolicyValue)
{
    if (PolicyValue == Policy.RemoteSigned)
    {
        cout << "\nSetting policy to RemoteSigned.. " << endl;
        system("powershell Set-ExecutionPolicy -Scope CurrentUser RemoteSigned");
        system("powershell Get-ExecutionPolicy");
        cout << endl;
    }
    else if (PolicyValue == Policy.Restricted)
    {
        cout << "\nSetting policy to Restricted.." << endl;
        system("powershell Set-ExecutionPolicy -Scope CurrentUser Restricted");
        system("powershell Get-ExecutionPolicy");
        cout << endl;
    }
    else if (PolicyValue == Policy.RemoteSignedAdmin)
    {
        // Requires admin privledge elevation
        // todo
        cout << "\nSetting policy to RemoteSigned.. " << endl;
        system("powershell Set-ExecutionPolicy RemoteSigned");
        system("powershell Get-ExecutionPolicy");
        cout << endl;
    }
    else if (PolicyValue == Policy.RestrictedAdmin)
    {
        cout << "\nSetting policy to Restricted.." << endl;
        system("powershell Set-ExecutionPolicy Restricted");
        system("powershell Get-ExecutionPolicy");
        cout << endl;
    }
}