# col-utilities

A series of scripts and programs to provide different utilities to the IT team



\# setup

To set up cutil properly, at the moment, a series of steps must be completed.



&#x20;- Install git: 

&#x09;winget install Microsoft.git

 - Clone this repository:

&#x09;git clone http://git-server:3000/colusa-county/utilities.git



&#x20;- Make sure the execution policy will allow PS1 scripts to execute:

&#x09;Set-ExecutionPolicy RemoteSigned



&#x20;- Step into the cloned repo:

&#x09;cd ./utilities



&#x20;- Initialize the application:

&#x09;./init.ps1





Afterwards, you will be in the cutil shell, type help for a list of scripts it has access to.

For more details on each script, type: help <script\_name>

