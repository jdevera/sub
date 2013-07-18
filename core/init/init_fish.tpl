# Configuration for ${sub} on the Fish shell.
# 
# Load ${sub} automatically by adding the following to ~/.config/fish/config.fish

# TODO: Find out how to get linebreaks from command substitution
set tmpinit (tempfile)
${sub_bin} init --full fish > $tmpinit
. $tmpinit
rm $tmpinit
set -e tmpinit

