# This is the full configuration that is required for full support of this
# Subdue sub '${sub}' under the Zsh shell.
# This text should be evalled by Zsh on startup. Add this to your
# ~/.zshenv
#
# Add to path
if ! [[ ":$$PATH:" == *":${sub_bin_dir}:"* ]]; then
    export PATH=$$PATH:${sub_bin_dir}
fi

# Wrapper to handle eval subcommands
function _subdue_${sub}_wrapper()
{
    local ret=0
    if [[ -z $$1 ]]; then
        env ${SUB}_SHELL=zsh ${sub}
        ret=$$?
    elif command ${sub} --is-sh "$$@"; then
        eval "$$(env ${SUB}_SHELL=zsh ${sub} "$$@")"
        ret=$$?
    else
        env ${SUB}_SHELL=zsh ${sub} "$$@"
        ret=$$?
    fi
    return $$ret
}

# Use the wrapper by default
alias ${sub}=_subdue_${sub}_wrapper

# Completion
if [[ -o interactive ]]; then

    compctl -K _${sub} ${sub}

    _${sub}() {
        local word words completions
        read -cA words
        word="$${words[2]}"

        if [ "$${#words}" -eq 2 ]; then
            completions="$$(env ${SUB}_SHELL=zsh ${sub} commands)"
        else
            completions="$$(env ${SUB}_SHELL=zsh ${sub} completions "$${word}")"
        fi

        reply=("$${(ps:\n:)completions}")
    }

fi

