# This is the full configuration that is required for full support of this
# Subdue sub '${sub}' under the Fish shell.
#
# This text should be evalled by Fish on startup. Add this to your
# ~/.config/fish/config.fish

# Add to path
if not contains ${sub_bin_dir} $$PATH
    set -x PATH $$PATH ${sub_bin_dir}
end

# Wrapper to handle eval subcommands
function _subdue_${sub}_wrapper

    if test -z "$$argv"
        command ${sub}
        return $$status
    else if command ${sub} --is-sh $$argv
        # TODO: Find out how to get linebreaks from command substitution
        set tmpinit (tempfile)
        command ${sub} $$argv > $$tmpinit
        . $$tmpinit
        set -l s $$status
        rm $$tmpinit
        return $$s
    else
        command ${sub} $$argv
        return $$status
    end
    return 1
end

# Use the wrapper by default
alias ${sub}=_subdue_${sub}_wrapper

# Completion
if status --is-interactive
    # TODO: Completion for FISH
end


