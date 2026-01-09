#include <string>
#include <iostream>
#include <vector>
#include <cctype>
using std::isdigit;
using std::string;
using std::vector;
using std::cout;
using std::cin;
using std::endl;
using std::stoi;
using std::to_string;

class ScriptList  {
  public:
    ScriptList(){};
    ~ScriptList(){};
    const int UninstallOutlookNew = 0;
    const int Backup = 1;
    const int Restore = 2;
    const int UninstallOneApp = 3;
    const int InstallOneApp = 4;
};

class ExecutionPolicy {
public:
    const int Restricted = 0;
    const int RemoteSigned = 1;
    const int RemoteSignedAdmin = 2;
    const int RestrictedAdmin = 3;
};

class MenuOptions {
public:
    const int MainMenu = 0;
    const int SoftwareMenu = 1;
    const int BackupRestoreMenu = 2;
};

class ScriptLauncher {

    public:
        ScriptLauncher();
        ~ScriptLauncher();

        void RenderMenu();
        void RenderSoftwareMenu();
        void RenderDataBackupMenu();

        void ClearScreen();

        void Initialize();

        void ParseInput(string Input);
        
        void ParseMenuInput(string Input);

        void UninstallMSAppScript();
        void InstallMSAppScript();
        void BackupScript();
        void RestoreScript();
        void BgInfoInstallScript();
        void DefaultUninstallApps();
        void UninstallOutlookNew();
        void SetExecutionPolicy(int Policy);
        void ListInstalledApps();

        void ParseCommands();

    private:
        string CommandReturn;
        bool MenuActive;

        MenuOptions Menu;
        ScriptList Scripts;
        ExecutionPolicy Policy;

        int SanitizeInput(string Input);
};

