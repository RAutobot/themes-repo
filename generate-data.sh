#!/bin/bash
set -o pipefail

mkdir public
jq -r '
    to_entries[] | .key as $code | .value |
    to_entries[] | .key as $owner | .value |
    to_entries[] | .key as $rb | .value[] as $path |
    ($rb | split("/")) as $parts | $parts[0] as $repo | $parts[1] as $branch |

    "\($code) \($owner) \($repo) \($branch) \($path)"
' themes | xargs -n 5 -P 20 bash -c '
    code="$1"
    owner="$2"
    repo="$3"
    branch="$4"
    path="$5"

    url="https://cdn.statically.io/$code/$owner/$repo/$branch/$path.json"

    curl -sLf "$url" | jq -c --arg owner "$owner" --arg url "$url" --arg repoUrl "https://github.com/$owner/$repo" --arg filename "${path##*/}" '\''.manifest | {
        name: (.name // $filename),
        version: (.version // "1.0.0"),
        author: (.author // $owner),
        url: $url,
        repoUrl: $repoUrl,
        filename: "\($filename).json"
    }'\'' || printf "[404 NOT FOUND] %s\n" "$url" >&2
' _ | jq -s 'sort_by(.name)' > public/data.json
