if [[ $# -lt 2 ]]; then
  echo """
Usage
  gitpass <action> <repo>

Example:
      
  gitpass clone https://gitlab.com/user/repo.git
"""
  return
fi


GITCMD=$1
echo $2 | sed -nr 's%.*(gitlab.com|github.com)/(.*)/(.*)$%\1 \2 \3%gp' | read -A PARTS


PROVIDER=$PARTS[1] 
GITUSER=$PARTS[2]
REPO=$PARTS[3]


AUTH="igorovic:$(pass show $PROVIDER/$GITUSER)"

eval "git $GITCMD https://$AUTH@$PROVIDER/$GITUSER/$REPO"
