# the structure

## Hard sub
bin/subdue
    The executable, bin gets added to the path on init
core/
    Internal files: completion templates, init templates, python code, bash helpers. Internal structure TBD
lib/
    Helper script location for user. Stuff used internally, but not exposed on the sub
commands/
    The sub commands
share/
    User location for files that are not executable

## Thin sub

Does not have a core directory

# How to install

pip install subdue

TODO: From github

# How to create you own sub

`subdue create <sub-name>`
Creates a sub called <sub-name> in the current directory. Then provides the
information necessary to install it, so as running sub-name init

# How to add scripts

In the commands directory of your sub, add some executable script. It is now a subcommand of your sub.

If you add a directory, it is a subcommand container, you can have more scripts inside.

Non-executable files in the commands directory are ignored

You can symlink scripts inside commands to provide aliases.  This is something
I wanted to do with a mappings file like sm, but it becomes too complex: not
worth it

Scripts do not require prefixes with the name of the sub, this is not
necessary. the old sub looked for commands with that prefix in the whole path,
subdue only looks for them in the commands directory.

# The path available to scripts

bin is always in the path. It is added explicictly if it's not there already
execlib is in the path
Then there is the question of whether commands should be in the path. I'm leaning towards the no, since one can always call subdue to run anything

# Environment variables exported byt subdue

 - `SUBDUE_ROOT`:
    The root directory of the sub
 - `SUBDUE_COMMAND`:
    The command tokens for the currently executed commands. For example, a
    command called foo under commands/bar/baz/foo called like this:
    `sub-name bar baz foo --ref A -f`
    will get "bar baz foo" in this variable.
    This can be used, for example, to show usage regardless of what alias has
    been used, or to call help on the command:
    `sub-name help $SUBDUE_COMMAND`
 - `SUBDUE_COMMAND_PATH`:
    The full path to the current command. It can be used to extract metadata
    from the currently running script from some common libraries.
 - `SUBDUE_IS_EVAL`:
    Set to 1 for sh-type scripts. It can be used in common functions to
    determine whether to do something or to output the commands to do the same
    thing.
 - `SUBDUE_DEBUG_FILE`: When sub is called with the --debug-command option, it
   will export in this variable the name of the file to send log output to. A
   subcommand can opt in to provide log information if this variable is set.
 - `SUBDUE_SHELL`: The name of the shell running the command. Usefull for eval
   scripts to figure out how to print their output.
   Also useful for completion.

# Eval commands

Sometimes you'll want to write a command that alters the current shell status,
like setting variables or changing the directory. This cannot be done from s
cript since all changes affect only the script and its children, but not the
parent process: the running shell.

Subdue provides a mechanism with which you can alter the status of the current
shell. This is called eval scripts. Eval scripts are a special type of scripts
that output a series of shell commands on stdout.

One of the things subdue init does is to create a shell function with the name
of your sub. If the command you are running is an eval command, it's output
will be evalled in the current shell, if it's a regular command, it will simply
run it.

Special care must be taken when writing eval commands if you want your sub to
be usable across different shells, since the way to perform the same actions
might differ. For instance, in bash and zsh, one exports a varaible like this:

    export FOO=bar

Whereas in the Fish shell, one exports a variable like this:

    set -x FOO bar

How does subdue know that a command is an eval command? Because they have a
special name, the use the prefix `sh-`. This prefix is removed when offering
completions and when showing the command in the summaries view. The prefix is
also excluded in the command tokens exported in `SUBDUE_COMMAND`.

For testing purposes, once can see the output that will be evalled by simply
calling the command with the sh- prefix.

for example, `sub cdme` will change the directory to $HOME but `sub sh-cdme`
will show `cd $HOME`.

subdue sets the variable `SUBDUE_EVAL` to 1, regardless of how whether the
script is being run with or without the sh- prefix.

# Default commands and flags

## Flags for subdue
 Most of these flags are used to set variables for the subcommands or internally for various reasons
 - `-h`, `--help`. Calls the *help* internal subcommand
 - `--is-sh`. Intended for internal use only. It checks whether the command that follows is an eval command or not. This produces no output, the answer can be checked in the return code: 0 means it is an eval command, 1 means it is a regular command.
TODO: Add some logging options here.
 - `-d`, `--debug` <file> Enable debug for subdue itself
 - `-s`, `--debug-command` <file> Enable debug on commands. If the command does not output any debug info, subdue will print message in the log saying so.
 - `-r`, `--resolve`: Output the full path of the command whose tokens follow. does not actually run the command.

## Internal subcommands

 - `help`: Shows help for a given script. Help is called by default when a
   command container is run.  Can take either the commands tokens, in which
   case it will first resolve the command to its full path, or a full path
   directly, in which case it assumes it is a container and prints its help
   straight away.

    TODO: Make this a flag: --container
    --usage <command> | <command-path>
    Shows the usage of a given command: Used in the library functions

 - `init`: Sets up the current sub in the running shell.

 - `commands`: Used internally to retrieve a list of available commands under
   the root of commands or on a given container.
    `--complete`: A flag used when calling commands for completion
    `--sh`: Show only eval commands, with the prefix stripped
    `--no-sh`: Show only regular commands

 - `completions`: Internal command to generate completions for shell completions


# the library

If you are writing your subcommands in bash, subdue provides you with some utility functions that you can use right away:

Import your functions with
`. subdue_functions.bash`

 - echoe: Prints a message to standard error. It understand eval mode
 - die: Print error to stderr and exit. Eval aware.
 - usage_error: Print usage and exit. Eval aware. Takes no arguments.

 TODO: Check if these work in zsh scripts.
 TODO: Check eval awareness is correct in bash, sh, zsh, fish
