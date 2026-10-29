USERNAME="anthonywu26"
REPONAME="C30-sandbox-setup-script"
USEREMAIL="anthonywu26@gmail.com"
NAME="Anthony"
REPOS=("git-intro" "holbertonschool-shell" "holbertonschool-low_level_programming")

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


echo "and downloading your repos";
for r in "${REPOS[@]}"; do
	if [ ! -d "$HOME/$r" ]; then
		git clone "https://github.com/$USERNAME/$r.git";
	fi
done;

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
