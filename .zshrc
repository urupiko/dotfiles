#-------------------------------------------------------------------------------
# HISTORY
#-------------------------------------------------------------------------------

# ヒストリファイルパス
HISTFILE=~/.zsh_history
# メモリにのせる履歴数
HISTSIZE=2000
# ファイルに記録する履歴数
SAVEHIST=5000

# 有効にした場合、ヒストリテキストファイルに実行時刻と実行時間が記録される
# 多分そこまで実行時刻を気にすることはないと思うので無効
#setopt extended_history

# 直前に実行したコマンドと同じならヒストリに記録しない
setopt hist_ignore_dups
# 履歴中の重複行をファイル記録前に無くす
setopt hist_ignore_all_dups       
# スペースで始まるコマンドはヒストリに入れない
setopt hist_ignore_space

# 履歴を共有
setopt share_history

#-------------------------------------------------------------------------------
# CHANGING DIRECTORIES
#-------------------------------------------------------------------------------

# cdで自動的にpushd。cd -<tab>目当て。
# 同じディレクトリはpushdしない
DIRSTACKSIZE=100
setopt auto_pushd
setopt pushd_ignore_dups

# ディレクトリ名入力でcd
setopt auto_cd

#-------------------------------------------------------------------------------
# COLOR
#-------------------------------------------------------------------------------

# ls結果の色づけ
export LSCOLORS=exfxcxdxbxegedabagacad
alias ls="ls -G"

# ls補完結果にも色づけ
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# プロンプト色拡張用
autoload colors
colors

#-------------------------------------------------------------------------------
# COMPLETION
#-------------------------------------------------------------------------------

# Git補完強化 (とりあえず保留)
# fpath=(~/gitroot/zsh-completions/src $fpath)

# 補完機能を有効 (.zcompdumpファイルが生成される)
autoload -Uz compinit
compinit

# 大文字、小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

#ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

#-------------------------------------------------------------------------------
# PROMPT
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
# UTILITY
#-------------------------------------------------------------------------------

function alc() {
    if [ -n "$1" ]; then
        w3m "http://eow.alc.co.jp/${1}/UTF-8/?ref=sa" | sed '1,36d' | less
    else
        echo 'usage: alc word'
    fi
}

function ptvi () {
  vi $(pt "$@" | peco --query "$LBUFFER" | awk -F : '{print "+" $2 " " $1}')
}

alias pp='pwd | pbcopy'

# alias vi='/usr/local/bin/nvim'

#-------------------------------------------------------------------------------
# LOCAL SETTINGS 
#-------------------------------------------------------------------------------

if [ -e .zshrc.local ]; then
  source .zshrc.local
fi

#-------------------------------------------------------------------------------
# Filer
#-------------------------------------------------------------------------------

ranger-cd () {
    tempfile='/tmp/chosendir'
    ranger --choosedir="$tempfile" "${@:-$(pwd)}" < $TTY
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
    zle reset-prompt
}
zle -N ranger-cd

vifm-cd () {
    tempfile='/tmp/chosendir'
    vifm --choose-dir="$tempfile" "${@:-$(pwd)}" < $TTY
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
    zle reset-prompt
}
zle -N vifm-cd 

#-------------------------------------------------------------------------------
# Zaw
#-------------------------------------------------------------------------------

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 500 # cdrの履歴を保存する個数
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':completion:*' recent-dirs-insert both

source ~/.zsh/zaw/zaw.zsh
zstyle ':filter-select:highlight' selected fg=white,bg=black,standout
zstyle ':filter-select' case-insensitive yes

#-------------------------------------------------------------------------------
# KEY BIND
#-------------------------------------------------------------------------------
# モード変更遅延を0.1秒に短縮 (デフォルト0.4秒？)
export KEYTIMEOUT=1

# vi キーバインドを使用
bindkey -d # reset
bindkey -v # vi mode

# 複数行入力
bindkey '^j' self-insert

# bindkey '^o' ranger-cd
bindkey '^v' vifm-cd

bindkey '^@' zaw-cdr
bindkey '^R' zaw-history
bindkey '^X^P' zaw-process
bindkey '^A' zaw-tmux

bindkey -r '^k'

# k で上書きできなかったので大人しくカスタマイズをやめる
autoload -U filter-select; filter-select -i
bindkey -M filterselect '^k' up-line-or-history
bindkey -M filterselect '^j' down-line-or-history

#-------------------------------------------------------------------------------
# AUTO EXEC
#-------------------------------------------------------------------------------

# tmux自動起動
if [[ ! -n $TMUX ]]; then
  ID="`tmux list-sessions`"
  if [[ -z "$ID" ]]; then
    tmux new-session
  fi
  create_new_session="Create New Session"
  ID="$ID\n${create_new_session}:"
  ID="`echo $ID | peco | cut -d: -f1`"
  if [[ "$ID" = "${create_new_session}" ]]; then
     tmux new-session
  fi
  tmux attach-session -t "$ID" 
fi
