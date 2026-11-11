# Set variables if not passed.
if [[ -n "$1" ]]; then
    INSTALLER_LINK="$1"
else
    read -rp "Enter installer link: " INSTALLER_LINK
fi

if [[ -n "$2" ]]; then
    USEREMAIL="$2"
else
    read -rp "Enter user email: " USEREMAIL
fi

if [[ -n "$3" ]]; then
    NAME="$3"
else
    read -rp "Enter user name: " NAME
fi

# Configure bash.
echo "hello geting bashrc";
if [[ -f $HOME/.bashrc ]]; then
    mv $HOME/.bashrc $HOME/.bashrc.bak;
fi
wget -qO $HOME/.bashrc "https://raw.githubusercontent.com/${INSTALLER_LINK}/config/.bashrc"

echo "hello geting bash_aliases";
if [[ -f $HOME/.bash_aliases ]]; then
    mv $HOME/.bash_aliases $HOME/.bash_aliases.bak;
fi
wget -qO $HOME/.bash_aliases "https://raw.githubusercontent.com/${INSTALLER_LINK}/config/.bash_aliases"

source $HOME/.bashrc

# Configure emacs.
echo "hello geting emacs config";
if [[ -f $HOME/.emacs.d/init.el ]]; then
    mv $HOME/.emacs.d/init.el $HOME/.emacs.d/init.el.bak;
fi
mkdir $HOME/.emacs.d
wget -qO $HOME/.emacs.d/init.el "https://raw.githubusercontent.com/${INSTALLER_LINK}/config/init.el"

# Configure git.
git config --global user.email "$USEREMAIL";
git config --global user.name "$NAME";
git config --global credential.helper 'cache --timeout=7200';

# Clone git repos.
echo "hello getting repository list";
RESPONSE_RAW=$(curl -s -w "\n%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(\
        printf "protocol=https\nhost=github.com\n" |\
        git credential fill |\
        tee >(git credential approve) |\
        grep 'password' | cut -d '=' -f 2\
    )" \
    -H "X-GitHub-Api-Version: 2026-03-10" \
    "https://api.github.com/user/repos");

RESPONSE=$(head -n -1 <<< "$RESPONSE_RAW");
RESPONSE_STATUS=$(tail -n 1 <<< "$RESPONSE_RAW");

if [[ "$RESPONSE_STATUS" == "200" ]]; then
    REPOS=(\
        $(grep '"full_name":' <<< "$RESPONSE" | cut -d ':' -f 2 | tr -d ' ,' | tr '\n' ' ')\
    )

    echo "got repository list, installing fzf...";

    sudo apt-get install -qq fzf > /dev/null;
    SELECTED_REPOS=(\
        $(printf "%s\n" "${REPOS[@]}" |\
            fzf --multi --height=40% --reverse --border --cycle\
            --prompt="Select repositories to clone (Tab to mark, Enter to confirm, Esc for no selection) > " |\
            tr -d '"')\
    )

    echo "and downloading your repos";
    for r in "${SELECTED_REPOS[@]}"; do
        repo_name=$(cut -d '/' -f 2 <<< "$r");
        if [ ! -d "$HOME/$repo_name" ]; then
            git clone "https://github.com/$r.git" "$HOME/$repo_name";
        fi
    done;

elif [[ "$RESPONSE_STATUS" == "401" ]]; then
    echo "Error: bad credentials - invalid Github token"
elif [[ "$RESPONSE_STATUS" == "418" ]]; then
    echo "Error? server is a teapot"
else
    echo "Error: wget failed with status: $RESPONSE_STATUS"
fi

# Setup betty linter.
git clone https://github.com/hs-hq/Betty.git $HOME/betty
sudo $HOME/betty/install.sh > /dev/null

# Add betty linter command to $PATH
cat <<'EOF' >betty
#!/bin/bash
# Simply a wrapper script to keep you from having to use betty-style
# and betty-doc separately on every item.
# Originally by Tim Britton (@wintermanc3r), multiargument added by
# Larry Madeo (@hillmonkey)

BIN_PATH="/usr/local/bin"
BETTY_STYLE="betty-style"
BETTY_DOC="betty-doc"

if [ "$#" = "0" ]; then
    echo "No arguments passed."
    exit 1
fi

for argument in "$@" ; do
    echo -e "\n========== $argument =========="
    ${BIN_PATH}/${BETTY_STYLE} "$argument"
    ${BIN_PATH}/${BETTY_DOC} "$argument"
done
EOF
chmod a+x $HOME/betty/betty
sudo mv $HOME/betty/betty /bin/

# Remove default directories and files.
DF=("empty_directory" "my_school" "not_here" "old_school" "ready_to_be_removed" "school");
echo "removing defualts!";
for d in "${DF[@]}"; do
    if [[ -d "$HOME/$d" || -f "$HOME/$d" ]]; then
        rm -r "$HOME/$d";
    fi;
done
