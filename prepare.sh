#!/usr/bin/env bash


chmod_files()
{
    for file in "$1"/*; do
        [[ ! -d $file ]] && chmod +x "$file"
    done
}

make_new_path()
{
    local path="$1"
    local dir="$(dirname "$path")"
    local base="$(basename "$path" | sed "s/^sub/${SUBNAME}/g")"
    echo "$dir/$base"
}

prepare_sub() {
    local path="$1"
    local newpath="$(make_new_path "$path")"

    if [[ -d $path ]]; then
        for file in "$path"/sub-*; do
            prepare_sub "$file"
        done
        chmod_files "$path"
    elif [[ -f $path ]]; then
        sed -i "s/\bsub\b/$SUBNAME/g;s/\b_SUB_ROOT\b/_$ENVNAME/g" "$path"
    fi

    mv "$path" "$newpath"
}


NAME="$1"
if [[ -z $NAME ]]; then
    echo "usage: prepare.sh NAME_OF_YOUR_SUB" >&2
    exit 1
fi

SUBNAME=$(echo $NAME | tr '[A-Z]' '[a-z]')
ENVNAME="$(echo $NAME | tr '[a-z-]' '[A-Z_]')_ROOT"

echo "Preparing your '$SUBNAME' sub!"

if [[ $NAME != "sub" ]]; then
    rm bin/sub

    for file in **/sub*; do
      prepare_sub "$file"
    done

    chmod_files "libexec"

    ln -s ../libexec/$SUBNAME bin/$SUBNAME
fi

rm README.md
rm prepare.sh

cat << DONEMSG
Done! Enjoy your new sub! If you're happy with your sub, run:

    rm -rf .git
    git init
    git add .
    git commit -m 'Starting off $SUBNAME'
    ./bin/$SUBNAME init

You can remove the example when you no longer need it:

   rm -r libexec/${SUBNAME}-example

Made a mistake? Want to make a different sub? Run:

    git add .
    git checkout -f

Thanks for making a sub!
DONEMSG
