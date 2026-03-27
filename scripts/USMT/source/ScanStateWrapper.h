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
    /**
     * Constructor for the ScanStateWrapper class.
     */
    ScanStateWrapper();

    /**
     * Destructor for the ScanStateWrapper class.
     */
    ~ScanStateWrapper();

    /**
     * Scans the computer for user data.
     * @param input The input string containing user information.
     */
    void Scan(string input);
    void Scan() const;
    
    /**
     * Loads user data onto the computer.
     * @param input The input string containing user information.
     */
    void Load(string input);
    void Load() const;


    /**
     * Prints the help message.
     */
    void PrintHelpMessage();

    /**
     * Lists the available users.
     */
    void ListUsers();

    /**
     * Converts a string to a vector of strings.
     * @param input The input string.
     * @return A vector of strings.
     */
    vector<string> StringToVector(string input);

    /**
     * Sets the configuration file.
     * @param input The path to the configuration file.
     */
    void SetConfig(string input);
    
    /**
     * Gets the current configuration file.
     * @return The path to the current configuration file.
     */
    string GetConfigFile();

    /**
     * Gets the current software version.
     * @return The current software version.
     */
    string GetCurrentSoftwareVersion();

    /**
     * Sets the store directory.
     * @param input The path to the store directory.
     */
    void SetStoreDirectory(string input);

    /**
     * Gets the current store directory.
     * @return The path to the current store directory.
     */
    string GetStoreDirectory();

    /**
     * Sets the binary path.
     * @param input The path to the binary file.
     */
    void SetBinaryPath(string input);

    /**
     * Gets the current binary path.
     * @return The path to the current binary file.
     */
    string GetBinaryPath();

    /**
     * Lists the files in the current directory.
     */
    void ListCurrentDirectory();

    /**
    * Changes the working directory.
    * @param NewDirectory The path to the new working directory.
    */
    void ChangeWorkingDirectory(string NewDirectory);

    /**
     * Shows the current scan command configuration.
     * @return The scan command to be executed.
     */
    string ShowScanCommand() const;

    /**
     * Shows the current load command configuration.
     * @return The load command to be executed.
     */
    string ShowLoadCommand() const;

    /**
     * Updates the command configurations with the current values of the member variables.
     */
    void UpdateCommand();

    /**
     * Sets the GUI mode.
     * @param toggle The boolean value to set the GUI mode.
     */
    void SetGUIMode(bool toggle);
    /**
     * Gets the current GUI mode.
     * @return The boolean value representing the GUI mode.
     */
    bool GetGUIMode() const;

private:
    /** The path to the configuration file. */
    string ConfigFile = "";

    /** The prompt for user input. */
    string Prompt = "";

    /** The current software version. */
    string Version = "";

    /** The path to the store directory. */
    string StoreDirectory = "";

    /** The path to the binary files. */
    string BinaryPath = "";

    /** The load command to be executed. */
    string LoadCommand = "";

    /** The scan command to be executed. */
    string ScanCommand = "";
    
    /** The boolean value representing the GUI mode. */
    bool GUIMode = false;
};