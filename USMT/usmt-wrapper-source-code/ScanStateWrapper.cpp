#include "ScanStateWrapper.h"

ScanStateWrapper::ScanStateWrapper()
{
    ConfigFile = ".\\MigCustom.xml";
    Prompt = "";
    Version = "0.0.5";
    StoreDirectory = "C:\\Users\\%USERNAME%\\Desktop\\store";
    BinaryPath = ".\\USMT\\amd64\\";

    UpdateCommand();
}

ScanStateWrapper::~ScanStateWrapper()
{
    delete this;
}

string ScanStateWrapper::GetConfigFile()
{
    return ConfigFile;
}

void ScanStateWrapper::PrintHelpMessage()
{
    cout << endl;
    cout << "\t\tUSMT Wrapper Command Help: " << endl;
    cout << "._____________________________________________________________________________________________________________________." << endl;
    cout << "|                                                                                                                     |" << endl;
    cout << "| ~>> version ------------------------------- Displays the current version of this software.                          |" << endl;
    cout << "|                                                                                                                     |" << endl;
    cout << "| ~>> scan {user1, user2, userX} ------------ Scans the computer for users and their data.                            |" << endl;
    cout << "|                                             If a users list is not specified it will grab all users.                |" << endl;
    cout << "|                                                                                                                     |" << endl;
    cout << "| ~>> load {user1, user2, userX} ------------ Loads the computer with the data from the scan stored on the desktop.   |" << endl;
    cout << "|                                             Specifically looks for a C:\\Users\\%USERNAME%\\Desktop\\store path with    |" << endl;
    cout << "|                                             the .MIG file being inside the store folder.                            |" << endl;
    cout << "|                                                                                                                     |" << endl;
    cout << "| ~>> show {store, binary, config, users} --- Shows the current value of the property passed in (config, store)       |" << endl;
    cout << "|                                                                                                                     |" << endl;
    cout << "| ~>> set {store, binary, config} {value} --- Sets the value of the field passed in,                                  |" << endl;
    cout << "|                                             ie: >> set config C : \\PathTo\\MyFile.xml                                | " << endl;
    cout << "|                                                                                                                     |" << endl;
    cout << "| ~>> toggle {colors} ----------------------- Fun mode engaged! Toggle only has one option at the moment, colors!     |" << endl;
    cout << "|                                                                                                                     |" << endl;
    cout << "|_____________________________________________________________________________________________________________________|" << endl;
    cout << "|Command Examples:                                                                                                    |" << endl;
    cout << "|      {USMT}~>> scan hgraves bstrickland sjuarez apatterson <-- This will only capture these listed user profiles    |" << endl;
    cout << "|      {USMT}~>> load hgraves bstrickland sjuarez apatterson <-- Make sure your corresponding load command on the     |" << endl;
    cout << "|                                                                new machine matches the users you scanned            |" << endl;
    cout << "|      {USMT}~>> set config C:\\Users\\username\\Desktop\\MyCustomConfigFile.xml                                          |" << endl;
    cout << "|      {USMT}~>> show config                                                                                          |" << endl;
    cout << "|      ^^^^^^^^^^^^^^^^^^^^^  <-- This command will output the path to the config file that was just set.             |" << endl;    
    cout << "|                                                                                                                     |" << endl;
    cout << "| NOTE: To modify WHAT is captured (not who) you need to edit the MigCustom.xml file,                                 |" << endl;
    cout << "| or point this helper script to the file you DO want to use with the 'set' command.                                  |" << endl;
    cout << "|                                                                                                                     |" << endl;
    cout << "| The users that were scanned will be saved in a file called users.log that gets stored                               |" << endl;
    cout << "| in the same directory this program is sitting in, just as a reference when you move to the load command.            |" << endl;
    cout << "+---------------------------------------------------------------------------------------------------------------------+" << endl;
    cout << endl;
}

void ScanStateWrapper::UpdateCommand()
{
    string load_command = BinaryPath + "loadstate.exe " + StoreDirectory + " /i:" + ConfigFile;
    load_command += " /mu:*";
    load_command += " /c /v:13 /l:load.log";

    LoadCommand = load_command;

    string scan_command = BinaryPath + "scanstate.exe " + StoreDirectory + " /i:" + ConfigFile + " /ue:*\\*";
    scan_command += " /ui:* /o /c /v:13 /l:scan.log";

    ScanCommand = scan_command;
}

string ScanStateWrapper::GetCurrentSoftwareVersion()
{
    return Version;
}

vector<string> ScanStateWrapper::StringToVector(string input)
{
    string temp = "";
    vector<string> StringAsVector;
    for (int i = 0; i < input.length(); i++)
    {
        if (input[i] != ' ')
        {
            temp += input[i];
        }
        else
        {
            StringAsVector.push_back(temp);
            temp = "";
        }
        if (i == input.length() - 1)
        {
            StringAsVector.push_back(temp);
        }
    }
    StringAsVector.erase(StringAsVector.begin());

    return StringAsVector;
}

void ScanStateWrapper::SetConfig(string input)
{
    ConfigFile = input;
    UpdateCommand();
}

void ScanStateWrapper::Scan(string input)
{
    vector<string> scan_arguments = StringToVector(input);
    if (scan_arguments.size() >= 1 && scan_arguments[0] == "-l")
    {
        // we're doing local accounts
    }
    std::ofstream fout;
    fout.open("users-scanned.log");
    for (int i = 0; i < scan_arguments.size(); i++)
    {
        fout << scan_arguments[i] << endl;
    }
    fout.close();

    vector<string> flags;
    for (int i = 0; i < scan_arguments.size(); i++)
    {
        string text = " /ui:" + scan_arguments[i];
        flags.push_back(text);
        cout << text << endl;
    }
    string command = BinaryPath + "scanstate.exe "+ StoreDirectory +" /i:" + ConfigFile  + " /ue:*\\* ";
    for (int i = 0; i < flags.size(); i++)
    {
        command += flags[i];
    }
    command += " /o /c /v:13 /l:scan.log";

    cout << endl;
    cout << "EXECUTING: " << command << endl;
    system(command.c_str());
}

void ScanStateWrapper::Scan() const
{
    // scan when no users given
    system(ScanCommand.c_str());
}

void ScanStateWrapper::Load(string input)
{
    vector<string> load_arguments = StringToVector(input);
    for (int i = 0; i < load_arguments.size(); i++)
    {
        string user = load_arguments[i];
        load_arguments[i] = " /mu:" + user + ":" + user;
        cout << load_arguments[i] << endl;
    }

    string command = BinaryPath + "loadstate.exe "+ StoreDirectory +" /i:" + ConfigFile;

    for (int i = 0; i < load_arguments.size(); i++)
    {
        command += load_arguments[i] + " ";
    }
    command += " /c /v:13 /l:load.log";
    LoadCommand = command;
    cout << "EXECUTING: " << command << endl;
    system(command.c_str());

}

void ScanStateWrapper::Load() const
{
    // load when no users given
    system(LoadCommand.c_str());
}

void ScanStateWrapper::ListUsers()
{
    namespace fs = std::filesystem;
    const std::filesystem::path users{ "C:\\Users\\" };
    
    for (auto const& dir_entry : std::filesystem::directory_iterator(users))
    {
        cout << dir_entry.path() << endl;
    }
}

void ScanStateWrapper::SetStoreDirectory(string input)
{
    StoreDirectory = input;
    UpdateCommand();
}

string ScanStateWrapper::GetStoreDirectory()
{
    return StoreDirectory;
}

void ScanStateWrapper::SetBinaryPath(string input)
{
    BinaryPath = input;
    UpdateCommand();
}

string ScanStateWrapper::GetBinaryPath()
{
    return BinaryPath;
}

void ScanStateWrapper::ListCurrentDirectory()
{
    system("dir");
}

void ScanStateWrapper::ChangeWorkingDirectory(string NewDirectory)
{
    string cmd = "cd " + NewDirectory;
    system(cmd.c_str());
    cout << "system call to: " + cmd << endl;
    cout << "FEATURE CURRENTLY UNFINISHED" << endl;
}

string ScanStateWrapper::ShowScanCommand() const 
{
    return ScanCommand;
}

string ScanStateWrapper::ShowLoadCommand() const
{
    return LoadCommand;
}

void ScanStateWrapper::SetGUIMode(bool toggle)
{
    GUIMode = toggle;
}

bool ScanStateWrapper::GetGUIMode() const
{
    return GUIMode;
}