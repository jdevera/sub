#!/usr/bin/env bash



prepare_sub() {
    local path="$1"

    if [[ -d $path ]]; then
        for file in "$path"/*; do
            prepare_sub "$file"
        done
    elif [[ -f $path ]]; then
        sed -i "s/\b\(_\)\?subdue\b/\1$SUBNAME/g;s/\b_SUBDUE_\(\[A-Z\]\)\b/_${ENVNAME}_\1/g" "$path"
        if [[ $(basename $path) != 'doc.txt' ]]; then
            chmod +x "$path"
        fi
    fi
}


NAME="$1"
if [[ -z $NAME ]]; then
    echo "usage: prepare.sh NAME_OF_YOUR_SUB" >&2
    exit 1
fi

SUBNAME=$(echo $NAME | tr '[A-Z]' '[a-z]')
ENVNAME="$(echo $NAME | tr '[a-z-]' '[A-Z_]')"

echo "Preparing your '$SUBNAME' sub!"

if [[ $SUBNAME != "subdue" ]]; then
    mv bin/sub bin/$SUBNAME

    prepare_sub "commands"

fi

rm README.md prepare.sh VERSION

cat << DONEMSG
Done! Enjoy your new sub! If you're happy with your sub, run:

    rm -rf .git
    git init
    git add .
    git commit -m 'Starting off $SUBNAME'
    ./bin/$SUBNAME init

You can remove the example when you no longer need it:

   rm -r commands/example

Made a mistake? Want to make a different sub? Run:

    git add .
    git checkout -f

Thanks for making a sub!
DONEMSG
