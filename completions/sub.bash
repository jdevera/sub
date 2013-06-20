_sub() {
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(sub commands)" -- "$word") )
  else
    local completions="$(sub completions "${COMP_WORDS[@]:1}")"
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -o default -F _sub sub
