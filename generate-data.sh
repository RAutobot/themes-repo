#!/bin/bash

mkdir public
jq -r '
    to_entries[] | .key as $author | .value |
    to_entries[] | .key as $repo | .value[] as $path |
    "\($author) \($repo) \($path)"
' themes | xargs -n 3 -P 20 bash -c '
    author="$1"
    repo="$2"
    path="$3"

    url="https://cdn.statically.io/gh/$author/$repo/$path.json"
    repoUrl="https://github.com/$author/${repo%/*}"
    filename="${path##*/}.json"

    printf "Processing: $author/$repo/$path\n" >&2

    curl -sSL "$url" | jq -c --arg url "$url" --arg repoUrl "$repoUrl" --arg filename "$filename" '\''.manifest | { name, version, author, url: $url, repoUrl: $repoUrl, filename: $filename }'\''
' _ | jq -s 'sort_by(.name)' > public/data.json
