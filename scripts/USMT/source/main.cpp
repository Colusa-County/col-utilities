#include "ScanStateWrapper.h"
#include "ScriptUtil/ScriptCommand.h"

char* RED = "\033[31m";
char* GREEN = "\033[32m";
char* YELLOW = "\033[33m";
char* BLUE = "\033[34m";
char* MAGENTA = "\033[36m";
char* CYAN = "\033[36m";
char* END = "\033[0m";

// global. bad. oh well.
bool colors = false;

static void ComputeSelfHash()
{
    string hash = "";
    
}

void clear()
{
    for (int i = 0; i < 100; i++)
    {
        cout << endl;
    }
}

static bool ToggleColors(bool toggle)
{
    if (toggle)
    {
        RED = "\033[31m";
        GREEN = "\033[32m";
        YELLOW = "\033[33m";
        BLUE = "\033[34m";
        MAGENTA = "\033[36m";
        CYAN = "\033[36m";
        END = "\033[0m";
    }
    else
    {
        RED = "";
        GREEN = "";
        YELLOW = "";
        BLUE = "";
        MAGENTA = "";
        CYAN = "";
        END = "";
    }

    colors = !colors;
    return toggle;
}

static void LaunchMessage(ScanStateWrapper* SSW)
{
    cout << endl;
    cout << GREEN << "User State Migration Tool (wrapper) v" + SSW->GetCurrentSoftwareVersion() << END << endl;
    cout << CYAN;
    cout << "          _____                    _____                    _____                _____          " << endl;
    cout << "         /\\    \\                  /\\    \\                  /\\    \\              /\\    \\         " << endl;
    cout << "        /::\\____\\                /::\\    \\                /::\\____\\            /::\\    \\        " << endl;
    cout << "       /:::/    /               /::::\\    \\              /::::|   |            \\:::\\    \\       " << endl;
    cout << "      /:::/    /               /::::::\\    \\            /:::::|   |             \\:::\\    \\      " << endl;
    cout << "     /:::/    /               /:::/\\:::\\    \\          /::::::|   |              \\:::\\    \\     " << endl;
    cout << "    /:::/    /               /:::/__\\:::\\    \\        /:::/|::|   |               \\:::\\    \\    " << endl;
    cout << "   /:::/    /                \\:::\\   \\:::\\    \\      /:::/ |::|   |               /::::\\    \\   " << endl;
    cout << "  /:::/    /      _____    ___\\:::\\   \\:::\\    \\    /:::/  |::|___|______        /::::::\\    \\  " << endl;
    cout << " /:::/____/      /\\    \\  /\\   \\:::\\   \\:::\\    \\  /:::/   |::::::::\\    \\      /:::/\\:::\\    \\ " << endl;
    cout << "|:::|    /      /::\\____\\/::\\   \\:::\\   \\:::\\____\\/:::/    |:::::::::\\____\\    /:::/  \\:::\\____\\ " << endl;
    cout << "|:::|____\\     /:::/    /\\:::\\   \\:::\\   \\::/    /\\::/    / ~~~~~/:::/    /   /:::/    \\::/    /" << endl;
    cout << " \\:::\\    \\   /:::/    /  \\:::\\   \\:::\\   \\/____/  \\/____/      /:::/    /   /:::/    / \\/____/" << endl;
    cout << "  \\:::\\    \\ /:::/    /    \\:::\\   \\:::\\    \\                  /:::/    /   /:::/    /         " << endl;
    cout << "   \\:::\\    /:::/    /      \\:::\\   \\:::\\____\\                /:::/    /   /:::/    /         " << endl;
    cout << "    \\:::\\__/:::/    /        \\:::\\  /:::/    /               /:::/    /    \\::/    /          " << endl;
    cout << "     \\::::::::/    /          \\:::\\/:::/    /               /:::/    /      \\/____/             " << endl;
    cout << "      \\::::::/    /            \\::::::/    /               /:::/    /                           " << endl;
    cout << "       \\::::/    /              \\::::/    /               /:::/    /                            " << endl;
    cout << "        \\::/____/                \\::/    /                \\::/    /          A wrapper c:           " << endl;
    cout << "         ~~                       \\/____/                  \\/____/                 and more!     " << endl;
    cout << GREEN << "Type help for help!" << endl << endl;
}

int main()
{
    bool old_color_value = ToggleColors(false);
    bool running = true;
    string input = "";
    ScanStateWrapper* SSW = new ScanStateWrapper();
    ScriptCommand* SC = new ScriptCommand();

    if (SSW->GetGUIMode())
    {
        // launch GUI
        // ignore CLI
    }
    else
    {
        // use cli
        // cli command to launch gui?
    }

    clear();
    LaunchMessage(SSW);

    while (running) {
        if (old_color_value != colors)
        {
            // this means toggle colors was run, re-display the Launch message
            clear();
            LaunchMessage(SSW);
            old_color_value = colors;
        }
        cout.flush();
        cout << GREEN << "{" << END << "USMT" << GREEN << "}" << END << "~" << GREEN << ">" << END << "> " << END;
        
        cin >> input;

        /**
            Scan and load commands
        */
        if (input == "scan")
        {
            clear();
            getline(cin, input);
            if (input == "")
            {
                SSW->Scan();
            }
            else
            {
                SSW->Scan(input);
            }
        }
        else if (input == "load")
        {
            clear();
            getline(cin, input);
            if (input == "")
            {
                SSW->Load();
            }
            else
            {
                SSW->Load(input);
            }
        }


        /**
        *   Toggle command
        */
        else if (input == "toggle")
        {
            cin >> input;
            if (input == "colors")
            {
                old_color_value = ToggleColors(colors);
            }
        }


        /**
        *   Set command
        */
        else if (input == "set")
        {
            cin >> input;
            if (input == "config")
            {
                cin >> input;
                SSW->SetConfig(input);
                cout << endl;
                cout << "XML config file path set to: " + SSW->GetConfigFile() << endl;
                cout << endl;
            }
            else if (input == "store")
            {
                cin >> input;
                SSW->SetStoreDirectory(input);
                cout << endl << "Store path set to: " << SSW->GetStoreDirectory() << endl << endl;
            }
            else if (input == "binary")
            {
                cin >> input;
                SSW->SetBinaryPath(input);
                cout << endl << "Binary path set to: " << SSW->GetBinaryPath() << endl << endl;
            }
        }


        /**
        *   Show command
        */
        else if (input == "show")
        {
            cin >> input;
            if (input == "store")
            {
                cout << SSW->GetStoreDirectory() << endl << endl;
            }
            else if (input == "config")
            {
                cout << "Current XML config file path:  " << SSW->GetConfigFile() << endl << endl;
            }
            else if (input == "users")
            {
                SSW->ListUsers();
            }
            else if (input == "binary")
            {
                cout << "Scan/Load State path: " + SSW->GetBinaryPath() << endl;
            }
            else if (input == "command" || input == "commands")
            {
                cout << "current command that will run upon scan/load:" << endl;
                cout << "\t scan: " + SSW->ShowScanCommand() << endl;
                cout << "\t load: " + SSW->ShowLoadCommand() << endl;
            }
            else if (input == "all")
            {
                // list all config itmes
                cout << endl;
                cout << "ALL CONFIG ITEMS: " << endl << endl;
                cout << " - Config File  : " + SSW->GetConfigFile() << endl;
                cout << " - Store Path   : " + SSW->GetStoreDirectory() << endl;
                cout << " - Binary Path  : " + SSW->GetBinaryPath() << endl;
                cout << " - Scan Command : " + SSW->ShowScanCommand() << endl;
                cout << " - Load Command : " + SSW->ShowLoadCommand() << endl;
                cout << endl;
            }
        }

        /**
        *   Help command
        */
        else if (input == "help")
        {
            clear();
            SSW->PrintHelpMessage();
        }

        // clear command
        else if (input == "clear")
        {
            clear();
        }

        // quit/exit commands
        else if (input == "exit" || input == "quit" || input == "q")
        {
            running = false;
        }

        // version output
        else if (input == "version" || input == "v")
        {
            cout << "USMT Wrapper version: " << SSW->GetCurrentSoftwareVersion() << endl;
            cout << endl;
        }

        else
        {
            // pass the command to a system call for the shell to handle
            system(input.c_str());
        }

        
    }

    return 0;
}