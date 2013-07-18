# This is the full configuration that is required for full support of this
# Subdue sub '${sub}' under the Bash shell.
# This text should be evalled by Bash on startup. Add this to your
# ~./bash_profile
# Add to path
if ! [[ ":$$PATH:" == *":${sub_bin_dir}:"* ]]; then
    export PATH=$$PATH:${sub_bin_dir}
fi

# Wrapper to handle eval subcommands
function _subdue_${sub}_wrapper()
{
    local ret=0
    if [[ -z $$1 ]]; then
        command ${sub}
        ret=$$?
    elif command ${sub} --is-sh "$$@"; then
        eval "$$(command ${sub} "$$@")"
        ret=$$?
    else
        command ${sub} "$$@"
        ret=$$?
    fi
    return $$ret
}

# Use the wrapper by default
alias ${sub}=_subdue_${sub}_wrapper

# Completion
function _${sub}()
{
    local word="$${COMP_WORDS[COMP_CWORD]}"

    if [[ "$$COMP_CWORD" -eq 1 ]]; then
        COMPREPLY=( $$(compgen -W "$$(command ${sub} commands)" -- "$$word") )
    else
        local completions="$$(command ${sub} completions "$${COMP_WORDS[@]:1}")"
        COMPREPLY=( $$(compgen -W "$$completions" -- "$$word") )
  fi
}

complete -o default -F _${sub} ${sub}
