export KEYTIMEOUT=1

autoload colors
colors

# COLOR
PROMPT='[%n]# '
RPROMPT='[%F{green}%d%f]'

function zle-line-init zle-keymap-select {
  case $KEYMAP in
    vicmd)
   # PROMPT="%{$fg[blue]%}[%{$reset_color%}%n/%{$fg_bold[red]%}NOR%{$reset_color%}%{$fg[blue]%}]%#%{$reset_color%} "
    PROMPT="[%{$reset_color%}%n/%{$fg_bold[red]%}NOR%{$reset_color%}]%#%{$reset_color%} "
    ;;
    main|viins)
   #  PROMPT="%{$fg[blue]%}[%{$reset_color%}%n/%{$fg_bold[cyan]%}INS%{$reset_color%}%{$fg[blue]%}]%#%{$reset_color%} "
    PROMPT="[%{$reset_color%}%n/%{$fg_bold[cyan]%}INS%{$reset_color%}]%#%{$reset_color%} "
    ;;
  esac
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

#Key
bindkey -d # reset
bindkey -v # vi mode

#Alias
alias pp='pwd | pbcopy'
