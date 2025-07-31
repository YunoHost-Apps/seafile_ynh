#!/bin/bash

set -eu

readonly app_name=seafile

source auto_update_config.sh

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
    local app_remote_version=$(echo "$docker_request_res" | jq -r '.name' | sort -V | grep -P '^\d+\.\d+\.\d+$'  | tail -n1)

    ## Check if new build is needed
    if [ "$app_version" != "$app_remote_version" ]
    then
        app_version="$app_remote_version"

        docker_request_res="$(curl -s 'https://hub.docker.com/v2/repositories/seafileltd/notification-server/tags' -H 'Content-Type: application/json' |
        jq -r '.results[]')"
        notification_remote_version=$(echo "$docker_request_res" | jq -r '.name' | sort -V | grep -P '^\d+\.\d+\.\d+$'  | tail -n1)

        docker_request_res="$(curl -s 'https://hub.docker.com/v2/repositories/seafileltd/sdoc-server/tags' -H 'Content-Type: application/json' |
        jq -r '.results[]')"
        seadoc_remote_version=$(echo "$docker_request_res" | jq -r '.name' | sort -V | grep -P '^\d+\.\d+\.\d+$'  | tail -n1)
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

        # Main image
        local docker_request_res="$(curl -s 'https://hub.docker.com/v2/repositories/seafileltd/seafile-mc/tags' -H 'Content-Type: application/json' |
            jq -r '.results[]')"
        local docker_main_checksum_amd64="$(echo "$docker_request_res" |
            jq -r 'select(.name == "'"$app_version"'") | .images[] | select(.architecture == "amd64") | .digest' |
            cut -d: -f2)"
        local docker_main_checksum_arm64="$(echo "$docker_request_res" |
            jq -r 'select(.name == "'"$app_version"'") | .images[] | select(.architecture == "arm64") | .digest' |
            cut -d: -f2)"

        # Notification server image
        docker_request_res="$(curl -s 'https://hub.docker.com/v2/repositories/seafileltd/notification-server/tags' -H 'Content-Type: application/json' |
            jq -r '.results[]')"
        local docker_notification_checksum_amd64="$(echo "$docker_request_res" |
            jq -r 'select(.name == "'"$notification_remote_version"'") | .images[] | select(.architecture == "amd64") | .digest' |
            cut -d: -f2)"
        local docker_notification_checksum_arm64="$(echo "$docker_request_res" |
            jq -r 'select(.name == "'"$notification_remote_version"'") | .images[] | select(.architecture == "arm64") | .digest' |
            cut -d: -f2)"

        # seadoc server image
        docker_request_res="$(curl -s 'https://hub.docker.com/v2/repositories/seafileltd/sdoc-server/tags' -H 'Content-Type: application/json' |
            jq -r '.results[]')"
        local docker_seadoc_checksum_amd64="$(echo "$docker_request_res" |
            jq -r 'select(.name == "'"$seadoc_remote_version"'") | .images[] | select(.architecture == "amd64") | .digest' |
            cut -d: -f2)"
        local docker_seadoc_checksum_arm64="$(echo "$docker_request_res" |
            jq -r 'select(.name == "'"$seadoc_remote_version"'") | .images[] | select(.architecture == "arm64") | .digest' |
            cut -d: -f2)"

        prev_main_sha256sum_amd64=$(get_from_manifest ".resources.sources.main.amd64.sha256")
        prev_main_sha256sum_arm64=$(get_from_manifest ".resources.sources.main.arm64.sha256")
        prev_notification_sha256sum_amd64=$(get_from_manifest ".resources.sources.notification_server.amd64.sha256")
        prev_notification_sha256sum_arm64=$(get_from_manifest ".resources.sources.notification_server.arm64.sha256")
        prev_seadoc_sha256sum_amd64=$(get_from_manifest ".resources.sources.seadoc.amd64.sha256")
        prev_seadoc_sha256sum_arm64=$(get_from_manifest ".resources.sources.seadoc.arm64.sha256")

        # Update manifest
        sed -r -i 's|version = "[[:alnum:].]{4,8}~ynh[[:alnum:].]{1,2}"|version = "'"${app_version}"'~ynh1"|' ../manifest.toml
        sed -r -i 's|"seafileltd/seafile-mc:[[:alnum:].]{4,10}"|"seafileltd/seafile-mc:'"${app_version}"'"|' ../manifest.toml
        sed -r -i 's|"seafileltd/notification-server:[[:alnum:].]{4,10}"|"seafileltd/notification-server:'"${notification_remote_version}"'"|' ../manifest.toml
        sed -r -i 's|"seafileltd/sdoc-server:[[:alnum:].]{4,10}"|"seafileltd/sdoc-server:'"${seadoc_remote_version}"'"|' ../manifest.toml
        sed -r -i "s|$prev_main_sha256sum_amd64|$docker_main_checksum_amd64|" ../manifest.toml
        sed -r -i "s|$prev_main_sha256sum_arm64|$docker_main_checksum_arm64|" ../manifest.toml
        sed -r -i "s|$prev_notification_sha256sum_amd64|$docker_notification_checksum_amd64|" ../manifest.toml
        sed -r -i "s|$prev_notification_sha256sum_arm64|$docker_notification_checksum_arm64|" ../manifest.toml
        sed -r -i "s|$prev_seadoc_sha256sum_amd64|$docker_seadoc_checksum_amd64|" ../manifest.toml
        sed -r -i "s|$prev_seadoc_sha256sum_arm64|$docker_seadoc_checksum_arm64|" ../manifest.toml

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
    msg="Build: $app_name version $app_version"

    echo "$msg" | mail.mailutils --content-type="text/plain; charset=UTF-8" -A "${app_name}_build_temp.log" -s "Autoupgrade $app_name : $result" "$notify_email"
fi
