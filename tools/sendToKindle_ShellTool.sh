#! /bin/bash

IFS=$'\n' files=($(zenity --file-selection --multiple --separator=$'\n' --title="Choose .mobi to send:" --file-filter='*.mobi'))

if [ $? -eq 0 ]
then
  s="Sending to Kindle ... \n"
  for i in ${files[@]}
  do
	s="$s \\n \t $i"
  done
  s="$s \n"

  sendToKindle_ShellTool.py  "${files[@]}" | zenity --progress --auto-close --text="$s"
fi

