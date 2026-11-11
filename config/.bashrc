source $HOME/.bash_aliases;

RED='\[\e[0;38;2;255;0;0;49m\]';
GREEN='\[\e[38;2;93;213;3m\]';
AE="\[\e[0m\]";

PS1="${GREEN}${RED}\u@sandbox:\w \n> ${AE}"
