set -u
set -e

noop() { echo "" > /dev/null; }

finish ()
{
    echo "Exiting... Ensuring repo is in a sane state."
    cd $DEST
    git checkout channel
}

echo "Will store nixpkgs repo at \"$DEST\""

echo "Will merge the following branches: \"$BRANCHES\""

REV=$(curl -Ls -o /dev/null -I -w %{url_effective} $CHANNEL)
REV=${REV##*.} # Truncate up to the last dot in the URL to get the git revision of the channel.
REV=${REV%/} # Truncate the trailing slash.

echo "Patching against revision \"$REV\""
# We sleep here to give the user time to press Ctrl+C if any of the above
# information is incorrect.
sleep 2

git clone "$REMOTE" "$DEST" || noop

cd "$DEST"

trap finish EXIT

# Add the remote with the changes we want to merge and fetch its branches.
git remote add upstream "$UPSTREAM" || noop
git fetch origin
git fetch upstream

git checkout upstream/master
git branch -D channel || noop
git checkout -b channel $REV

for branch in $BRANCHES; do
    git branch -D $branch || noop
    git checkout -b $branch origin/$branch
    git rebase --onto channel channel $branch
    git checkout channel
    git merge $branch
done
