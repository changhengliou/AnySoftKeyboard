#! /bin/bash

if (( $# != 1 )); then
    echo "Syntax: adb.sh [E|W|I|D|V]

    adb.sh outputs a logcat and filters out lines not related with this project.
    \`dalvikvm\`, \`System.err\` and \`AndroidRuntime\` are included, as those are used to debug fatal crashes.

    The only argument is the initial of your log priority. (Error/Warning/Info/Debug/Verbose)"
else
    # These variables are just to higlight text:
    color="\033[0;36m"
    nocolor="\033[0m"
    error="\033[0;31m"
    # Retrieving current working path
    oldpath="$(pwd)"
    echo -e "${color}Searching${nocolor} for tags in source code…"
    # cd project_root_folder
    # This will traverse from current folder to its parent folderwork until it finds a .git folder:
    cd "$(dirname "$0")"
    while [ ! -d ".git" ]
    do
        cd ..
        if [[ "$(pwd)" == "/" ]]; then
            echo -e "${error}Aborting.${nocolor} Not inside a Git project."
            exit 1
        fi
    done
    tags=`grep -R 'TAG = ".*"' app/src/main/java/com/* jnidictionaryv1/src/main/java/com/* jnidictionaryv2/src/main/java/com/*`
    # We can go back to our original folder now:
    cd "$oldpath"
    tags="$(echo $tags | sed -E 's![a-z/A-Z12]*\.java: (protected |private )?(static )?(final )?String [A-Z_]* = "([^\"]*)";!\4!g')"
    tags="$tags dalvikvm System.err AndroidRuntime "
    comm="adb logcat $(echo "$tags" | sed "s/ /:$1 /g")*:S"
    echo -e "${color}Running: $nocolor$comm"
    # Run command:
    echo -e "${color}Logcat:$nocolor"
    $comm
fi

