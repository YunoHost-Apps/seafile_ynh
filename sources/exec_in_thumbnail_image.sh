#/bin/bash

set -eu

readonly app="{{ app }}"
readonly install_dir="{{ install_dir }}"
readonly systemd_thumbnail_bind_mount="{{ systemd_thumbnail_bind_mount }}"

mkdir -p "/run/$app/pids"
systemd-run --wait --pipe --uid="$app" --gid="$app" \
    --property=RootDirectory="$install_dir"/seafile_image \
    --property="BindPaths=$systemd_thumbnail_bind_mount" \
    --property=EnvironmentFile="$install_dir"/seafile_env.conf \
    --property=WorkingDirectory=/opt/seafile/thumbnail-server \
    "$@"
