#/bin/bash

set -eu

readonly app="{{ app }}"
readonly install_dir="{{ install_dir }}"
readonly systemd_notification_server_bind_mount="{{ systemd_notification_server_bind_mount }}"

mkdir -p "/run/$app/pids"
systemd-run --wait --pipe --uid="$app" --gid="$app" \
    --property=RootDirectory="$install_dir"/seafile_image \
    --property="BindPaths=$systemd_notification_server_bind_mount" \
    --property=EnvironmentFile="$install_dir"/notification_server_env.conf \
    "$@"
