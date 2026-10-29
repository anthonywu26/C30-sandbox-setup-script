USERNAME="anthonywu26"
REPONAME="C30-sandbox-setup-script"
USEREMAIL="anthonywu26@gmail.com"
NAME="Anthony"

echo "hello geting bashrc";
if [[ -f ~/.bashrc ]]; then
  mv ~/.bashrc ~/.bashrc.bak;
fi
wget -qO ~/.bashrc "https://raw.githubusercontent.com/${USERNAME}/${REPONAME}/refs/heads/main/.bashrc"

echo "hello geting bash_aliases";
if [[ -f ~/.bash_aliases ]]; then
  mv ~/.bash_aliases ~/.bash_aliases.bak;
fi
wget -qO ~/.bash_aliases "https://raw.githubusercontent.com/${USERNAME}/${REPONAME}/refs/heads/main/.bash_aliases"

git config --global user.email "$USEREMAIL";
git config --global user.name "$NAME";
git config --global credential.helper 'cache --timeout=7200';

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

rmdf()
{
		DF=("empty_directory" "my_school" "not_here" "old_school" "ready_to_be_removed" "school");
		echo "Would you like to remove the defualt folders and files from the holberton sandbox";
		echo "${DF[*]}";
		read -p $'y/n: ' -r remove;
		if [[ "$remove" == "y" ]];then
			echo "removing defualts!";
			for d in "${DF[@]}"; do
				if [[ -d "$HOME/$d" || -f "$HOME/$d" ]]; then
					rm -r "$d";
				fi;
			done		
		else
			echo "righty-o, not removing";
		fi
}

rmdf
source ~/.bashrc
