#pragma once

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <filesystem>
using std::vector;
using std::string;
using std::cin;
using std::cout;
using std::endl;

class ScanStateWrapper
{
    public:
        ScanStateWrapper();
        ~ScanStateWrapper();

        void Scan(string input);
        void Scan() const;
        void Load(string input);
        void Load() const;

        void PrintHelpMessage();
        void ListUsers();

        vector<string> StringToVector(string input);

        void SetConfig(string input);
        string GetConfigFile();

        string GetCurrentSoftwareVersion();

        void SetStoreDirectory(string input);
        string GetStoreDirectory();

        void SetBinaryPath(string input);
        string GetBinaryPath();

        void ListCurrentDirectory();
        void ChangeWorkingDirectory(string NewDirectory);

        string ShowScanCommand() const;
        string ShowLoadCommand() const;

        void UpdateCommand();

        void SetGUIMode(bool toggle);
        bool GetGUIMode() const;

    private:
        string ConfigFile = "";
        string Prompt = "";
        string Version = "";
        string StoreDirectory = "";
        string BinaryPath = "";
        string LoadCommand = "";
        string ScanCommand = "";

        bool GUIMode = false;
};