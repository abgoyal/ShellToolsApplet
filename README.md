* ShellTools Applet:

ShellTools is an applet for the Cinnamon Desktop that makes it trivial to add shell commands as a panel popup menu

I initially wrote the ShellTools applet as a way to learn writing applets for Cinnamon. It is still quite useful by itself.

After installation, edit 
> tools.json
in
> ~/.local/share/cinnamon/applets/ShellTools@abgoyal/
and add the names of commands and the commandline you would like to show in the ShellTools popup menu.

Note that ShellTools recreats the menu each time the icon is clicked in the Cinnamon panel. It re-reads the list of tools from
> tools.json
when it builds the menu.

This allow quite a few fancy tricks. One of these is to update the tools using a deamon process periodically.

The netspeed ShellTools demonstrates how you could show your total download bytes and current net download speed this way.

Another tool, sendToKindle Shell Tool demonstrates how you can trivially combine zenity/gdialog/qtdialog to add gui support to your shell tools. 
It is not currently fully functional as support for passing environment variables is yet to be implemented. If you want to try it out meanwhile, edit
> sendToKindle_ShellTool.py
manually and replace the gmail username, password and kindle email address.

** TODO:
	- Add configuration option and right click menu
	- Pass configuration in process environment to the spawned commands

