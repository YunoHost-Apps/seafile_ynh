#!/bin/bash

set -eu

readonly app_name=seafile

get_from_manifest() {
    result=$(python3 <<EOL
import toml
import json
with open("../manifest.toml", "r") as f:
    file_content = f.read()
loaded_toml = toml.loads(file_content)
json_str = json.dumps(loaded_toml)
print(json_str)
EOL
    )
    echo "$result" | jq -r "$1"
}

check_app_version() {
    local docker_request_res="$(curl -s 'https://hub.docker.com/v2/repositories/seafileltd/seafile-mc/tags' -H 'Content-Type: application/json' |
        jq -r '.results[]')"
    local docker_digest_latest="$(echo "$docker_request_res" |
        jq -r 'select(.name == "latest") | .digest')"
    local app_remote_version=$(echo "$docker_request_res" |
        jq -r 'select(.digest == "'"$docker_digest_latest"'" and .name != "latest") | .name')

    ## Check if new build is needed
    if [[ "$app_version" != "$app_remote_version" ]]
    then
        app_version="$app_remote_version"
        return 0
    else
        return 1
    fi
}

upgrade_app() {
    (
        set -eu

        if [ "${app_prev_version%%.*}" != "${app_version%%.*}" ]; then
            echo "Auto upgrade from this version not supported. Major upgrade must be manually managed and tested."
            exit 1
        fi

        local docker_request_res="$(curl -s 'https://hub.docker.com/v2/repositories/seafileltd/seafile-mc/tags' -H 'Content-Type: application/json' |
            jq -r '.results[]')"
        local docker_checksum_amd64="$(echo "$docker_request_res" |
            jq -r 'select(.name == "'"$app_version"'") | .images[] | select(.architecture == "amd64") | .digest' |
            cut -d: -f2)"
        local docker_checksum_arm64="$(echo "$docker_request_res" |
            jq -r 'select(.name == "'"$app_version"'") | .images[] | select(.architecture == "arm64") | .digest' |
            cut -d: -f2)"

        prev_sha256sum_amd64=$(get_from_manifest ".resources.sources.main.amd64.sha256")
        prev_sha256sum_arm64=$(get_from_manifest ".resources.sources.main.arm64.sha256")

        # Update manifest
        sed -r -i 's|version = "[[:alnum:].]{4,8}~ynh[[:alnum:].]{1,2}"|version = "'"${app_version}"'~ynh1"|' ../manifest.toml
        sed -r -i 's|"seafileltd/seafile-mc:[[:alnum:].]{4,10}"|"seafileltd/seafile-mc:'"${app_version}"'"|' ../manifest.toml
        sed -r -i "s|$prev_sha256sum_amd64|$docker_checksum_amd64|" ../manifest.toml
        sed -r -i "s|$prev_sha256sum_arm64|$docker_checksum_arm64|" ../manifest.toml

        git commit -a -m "Upgrade $app_name to $app_version"
        git push gitea auto_update:auto_update
    ) 2>&1 | tee "${app_name}_build_temp.log"
    return "${PIPESTATUS[0]}"
}

app_prev_version="$(get_from_manifest ".version" |  cut -d'~' -f1)"
app_version="$app_prev_version"

if check_app_version
then
    set +eu
    upgrade_app
    res=$?
    set -eu
    if [ $res -eq 0 ]; then
        result="Success"
    else
        result="Failed"
    fi
    msg="Build: $app_name version $app_version\n"
    msg+="$(cat ${app_name}_build_temp.log)"
    echo -e "$msg" | mail.mailutils -a "Content-Type: text/plain; charset=UTF-8" -s "Autoupgrade $app_name : $result" "$notify_email"
fi
