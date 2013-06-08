# ShellTools Applet:

## tl;dr

Quite simply, This applet generates a dynamic, autoupdated popup menu like this:

<center>
<img src="ShellTools-1.png??raw=true">ShellTools Applet activated Screenshot</img>
</center>

<center>
![ShellTools Applet activated Screenshot](ShellTools-1.png??raw=true)
</center>

from a simple config file like this:

```
[ 
    ["Terminator", "terminator"], 
    ["Terminology (e11t)", "terminology"], 
    ["Send .mobi to Kindle", "sendToKindle_ShellTool.sh"],
    ["-"],
    ["!~NETS~~netspeed.sh wlan0~"],
    ["!~IPV6~notify-send -t 2000 ${IPV6}~ipv6monitor.sh~"],
    ["~DISK~~df -B GB $HOME | tail -n 1 | awk '{print \"Home:\",$4,\"free\"}'~","terminology -e watch df -h"],
    ["-"],
    ["!~DSFO~~echo -n "SFO: " ; TZ=US/Pacific date +'%a %b %-d, %I:%M %P'~"],
    ["!~DBOS~~echo -n "BOS: " ; TZ=US/Eastern date +'%a %b %-d, %I:%M %P'~"],
    ["!~DLON~~echo -n "LON: " ; TZ=Europe/London date +'%a %b %-d, %I:%M %P'~"],
    ["-"],
    [ "Edit Tools", "~EDIT~~echo gedit ${TOOLSFILE_IN}~"],
]
```

## Introduction
ShellTools is an applet for the Cinnamon Desktop that makes it trivial to add shell commands as a panel popup menu

I initially wrote the ShellTools applet as a way to learn writing applets for Cinnamon. It quickly became a very useful utility.

Install the applet as normal, add it to panel, and then click the applet icon in the panel. Select the "Edit Tools" menu option
to start adding your own custom tools.

ShellTools recreats the menu each time the icon is clicked in the Cinnamon panel. It re-reads the list of tools from
`tools.json` when it builds the menu. So all you need to do to see any changes you made to the tools.json.in, is to wait upto 15 seconds
and then click the applet icon.

This allow quite a few fancy tricks. Read on.

## Editing tools.json.in

The sample `tools.json.in` file included with applet demonstrates various ways of creating your own custom tools. It demonstrates eight different
types of tool entries. 

The entire `tools.json.in` file is a valid json-encoded array. It should be formatted cleanly, as it is being parsed later in bash, not with a proper
json parser. Do not place extraneous content in this file. Standard "//" prefixed comments are fine. Do __not__ include '~' anywhere as it has special meaning!

Going through each line in `tools.json.in` (listed above):

- Lines 2 & 3: These are the basic shortcut-like entries: Each entry is a 2-element JSON array. 
  The first element is a string that will become the label of the corresponding menu item. 
  The second element is the shell command to run when the entry is activated.
  Note that the shell command is spawned in a background process - if its a terminal-based application, you will see nothing.

- Line 4: This is also a shortcut, but refers to a custom script that might be installed in the users PATH anywhere. 
  It merely needs to be a valid script with a hash-bang header and execute permissions. Note again that this will be 
  run in the background, so you won't see any console output if its a console app. The applet also adds its own appletdir/tools directory
  in the PATH before searching for commands, so any scripts placed there can also be run similarly.

- Line 5: Inserts a "Seperator" into the popup menu. This is simply a 1-element JSON array.

- Line 6: This line defines an "informational" item with output substituition. It is simple a 1-element JSON array, as it executes no commands. 
  What marks it as a "non-interactive" entry is that its first character is "!". This "!" will be removed by the applet
  before setting up the menu, but it will cause the applet to make the particular entry "inactive".
  Next is another special character "~". This is a field seperator for output substitution.
  Output substitution is a powerful function ShellTools offers that allows one to dynamically update the content of the menu label (or command) 
  based on the output of a script. Each output substituition entry requires three fields delimited with `~`.

   - The first field is a small identifier, preferably 4-6 characters long, all capitals. It is used by the applet to maintain state. It _must_ be provided.

   -The second field is a "notify command" and is optional. In this particular entry, notify command has not been used.

   -The third field is the shell command whose output will be substituted. Here it is `netspeed.sh wlan0` which is a tool included with the applet that
   reports total network download and current download rates. 
  
  Thus the entire output substitution entry is `~NETS~~netspeed.sh wlan0~`. Note that the delimiter must be used at the beginning as well as end, not
  just between the fields. 
  
  Note also that as this entry is marked as "informational only", by prefixing it with `!`, the second element is not needed.

- Line 7: This is another informational item with output substitution. 
  The difference between the previous entry and this one is that it also uses the notify function.
  As explained, the second field in the output substitution entry is the notify command. Here it is set to `notify-send -t 2000 ${IPV6}`.
  `notify-send` is a gnome utility to send desktop notifications. The shell variable referenced in the notify command, `${IPV6}`, matches the 
  identified defined in the first field. This allows the command to refer to the notify-state of the command. Read the next section on how to set this.

- Line 8: This is another output substitution entry but this one is an active item, not simply "informational". 
  Thus, its a 2-element array, the second element defining the command to be run. 
  It also demonstrates how simple command sequences can be included in the tools file itself without having to save a new bash script.
  This is only recommended for the very simplest of cases, though.

- Line 9 is again a separator.

- Lines 10,11,12: These entries are further examples of informational-only items. They show the local times in three different time zones.
  Note the use of `echo -n` here preceding the date command so that the entire output is generated on one line.

- Line 14: Here, output substitution is used, not for the menul label text, but for the command text itself. The location of the tools file is
  inserted using a variable substitution. Note the use of `echo` here.


## Writing your own tool

Writing your own tool is easy. A tool is simply a shell script, placed in the users path somewhere, or in the tools/ directory under the main applet directory
(typically `~/.local/share/cinnamon/applets/ShellTools@abgoyal/`). 

The script may generate 1,2 or 3 lines of output. If it generates more, the 4th and subsequent lines are ignored. If it generates no output, you are doing it wrong.

The most general case is when the script generates three lines of output. In this case, the first line of output is the "notify state", the second line is 
"internal state" and the third line is the substitution text. 

If the script outputs exactly two lines, the first line is used both as the notify state as well as the internal state. The second line is used as the substitution text.

If the script outputs exactly one line, this line is used as the notify state, internal state as well as the substitution text.

### Notify state

notify state is simply a one-line opaque blob of text the script can output. This blob is saved by the applet without further processing. If on the next invocation of the script, the new notify state returned by the script is different, the applet calls the notify command, if defined. The applet passes the old and the new notify states to the notify command as environment variables named `IDENTIFIER_old` and `IDENTIFIER`, where `IDENTIFIER` is the short 4-6 character id defined as the first field of the output substitution item.

### Internal state

internal state is also a one-line opaque blob of text. When the subsitution command is run, the internal state is passed to it in the environment variable named `IDENTIFIER` 

### Subsitution text

This is the text that the applet will substitute in place of the substitution entry.

## Do-es and Don'ts

- Do not make your custom tools and command long running. For example, obtaining your externally visible IP using an api is a big no-no.
- A line in the tools.json.in file must contain exactly zero or one output substitution entries. Not more. 
- Do not use `~` anywhere in the tools.json.in file except as a field separator for output substitution. Otherwise things will break.

## FAQs

- Q: Why do this with bash?

  A: Minimizes dependencies. It would be a lot easier to do in python, but that would mean requiring python and various modules to be
     installed. Bash is essentially always present. Also bash is a much lighter process than python.

- Q: Why not simply process `tools.json.in` in the Applet code itself?

  A: Multiple reason:

    - The entries in tools.json.in are bash scripts. Its a lot simpler to process them in Bash. 
      There is no way to read output of a spawned bash script from inside an applet right now. Also, even if there were a way,
      it would require syncronous spawning, which would be dangerous in this context.
    - By spawning a single processing script (`processTools.sh`) in the background, we take it out of the applet critical path, 
      thus reducing chances of taking down/blocking/slowing the applet or Cinnamon itself.
    - `processTools.sh` itself can be edited while developing, without having to reload the applet. The applet will just call the new version 
      at the next update.

## TODO:
- Add configuration option and right click menu
    - Configuration option for update frequency
    - Centrally Enable/Disable notifications without having to manually change `tools.json.in`

