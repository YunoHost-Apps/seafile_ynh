source /usr/share/yunohost/helpers

#=================================================
# SET ALL CONSTANTS
#=================================================

readonly seafile_version=$(ynh_app_upstream_version)

readonly seafile_image="$install_dir/seafile_image"
readonly notification_image="$install_dir/notification_image"
readonly seadoc_image="$install_dir/seadoc_image"
readonly thumbnail_server_image="$install_dir/thumbnail-server_image"
readonly seafile_code="$seafile_image/opt/seafile/seafile-server-$seafile_version"

readonly time_zone="$(timedatectl show --value --property=Timezone)"
readonly python_version="$(python3 -V | cut -d' ' -f2 | cut -d. -f1-2)"
readonly systemd_base_bind_mount="/proc /dev /usr/share/zoneinfo "
systemd_seafile_bind_mount="$systemd_base_bind_mount"
systemd_seafile_bind_mount+="$data_dir/seafile-data:/opt/seafile/seafile-data "
systemd_seafile_bind_mount+="$data_dir/seahub-data:/opt/seafile/seahub-data "
systemd_seafile_bind_mount+="/run/$app/pids:/opt/seafile/pids "
systemd_seafile_bind_mount+="/var/log/$app:/opt/seafile/logs "
systemd_seafile_bind_mount+="$install_dir/conf:/opt/seafile/conf "
systemd_seafile_bind_mount+="$install_dir/ccnet:/opt/seafile/ccnet"

systemd_notification_server_bind_mount="$systemd_base_bind_mount"
systemd_notification_server_bind_mount+="$data_dir/notification-data:/opt/notification-data"

systemd_seadoc_bind_mount="$systemd_base_bind_mount"
systemd_seadoc_bind_mount+="$install_dir/seadoc-conf:/opt/sdoc-server/conf "
systemd_seadoc_bind_mount+="/var/log/$app:/opt/sdoc-server/logs"

systemd_thumbnail_bind_mount="$systemd_base_bind_mount"
systemd_thumbnail_bind_mount+="$data_dir/seafile-data:/opt/seafile/seafile-data "
systemd_thumbnail_bind_mount+="$data_dir/seahub-data:/opt/seafile/seahub-data "
systemd_thumbnail_bind_mount+="/var/log/$app:/opt/seafile/logs "
systemd_thumbnail_bind_mount+="$install_dir/conf:/opt/seafile/conf"

# Create special path with / at the end
if [[ "$path" == '/' ]]
then
    readonly path2="$path"
else
    readonly path2="$path/"
fi

if [ "${LANG:0:2}" == C. ] || [ "${LANG}" == C ]; then
    readonly language=en
else
    readonly language="${LANG:0:2}"
fi

if [ "$YNH_ARCH" == arm64 ]; then
    port_thumbnail="$port_seahub"
fi

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

run_seafile_cmd() {
    ynh_hide_warnings "$install_dir/scripts/exec_in_seafile_image.sh" "$@"
}

update_pwd_group_shadow_in_docker() {
    grep "^$app:x" /etc/passwd | sed "s|$install_dir|/opt/seafile|" >> "$1/etc/passwd"
    grep "^$app:x" /etc/group >> "$1/etc/group"
    grep "^$app:x" /etc/group- >> "$1/etc/group-"
    grep "^$app:"  /etc/shadow >> "$1/etc/shadow"
}

install_source() {
    # set correct seafile version in patch
    ynh_replace --match="__SEAFILE_VERSION__" --replace="$seafile_version" --file="$YNH_APP_BASEDIR"/patches/main/import_ldap_user_when_authenticated_from_remoteUserBackend.patch
    ynh_setup_source_custom --dest_dir="$seafile_image" --full_replace
    update_pwd_group_shadow_in_docker "$seafile_image"
    mkdir -p "$seafile_image/opt/seafile/"{seafile-data,seahub-data,conf,ccnet,logs,pids}

    ynh_setup_source_custom --dest_dir="$notification_image" --full_replace --source_id=notification_server
    update_pwd_group_shadow_in_docker "$notification_image"

    ynh_setup_source_custom --dest_dir="$seadoc_image" --full_replace --source_id=seadoc
    update_pwd_group_shadow_in_docker "$seadoc_image"
    mkdir -p "$seadoc_image/opt/sdoc-server/"{logs,conf}

    if [ "$YNH_ARCH" != arm64 ]; then
        ynh_setup_source_custom --dest_dir="$thumbnail_server_image" --full_replace --source_id=thumbnail_server
        update_pwd_group_shadow_in_docker "$thumbnail_server_image"
        mkdir -p "$thumbnail_server_image/opt/seafile/"{seafile-data,seahub-data,conf,logs}

        # workaround until https://github.com/haiwen/seafile-thumbnail-server/pull/11 is merged and released
        ynh_replace --match='config = uvicorn.Config(app, port=8088)' \
                    --replace="config = uvicorn.Config(app, port=$port_thumbnail)" \
                    --file="$thumbnail_server_image/opt/seafile/thumbnail-server/main.py"
    fi

    # Install exec scripts
    mkdir -p "$install_dir/scripts"
    for s in \
            exec_in_seafile_image.sh \
            exec_in_seadoc_image.sh \
            exec_in_seafile_notification_image.sh \
            exec_in_thumbnail_image.sh; do
        ynh_config_add --jinja --template="../sources/$s" --destination="$install_dir/scripts/$s"
        chmod 700 "$install_dir/scripts/$s"
        chown "root:root" "$install_dir/scripts/$s"
    done
}

configure_env_files() {
    ynh_config_add --jinja --template=seafile_env.j2 --destination="$install_dir"/seafile_env.conf
    ynh_config_add --jinja --template=seafile-notification_env.j2 --destination="$install_dir"/notification_server_env.conf
    ynh_config_add --jinja --template=seafile-doc_env.j2 --destination="$install_dir/seadoc_env.conf"
    ynh_config_add --jinja --template=seafile-thumbnail_env.j2 --destination="$install_dir/thumbnail_env.conf"
}

configure_systemd_services() {
    # Add Seafile Server to startup
    ynh_config_add_systemd --service="$app" --template=seafile.service
    ynh_config_add_systemd --service=seahub --template=seahub.service
    ynh_config_add_systemd --service="$app-notification" --template=seafile-notification.service
    ynh_config_add_systemd --service="$app-doc-server" --template=seafile-doc-server.service
    ynh_config_add_systemd --service="$app-doc-converter" --template=seafile-doc-converter.service
    if [ "$YNH_ARCH" != arm64 ]; then
        ynh_config_add_systemd --service="$app-thumbnail" --template=seafile-thumbnail.service
    fi
}

set_permission() {
    chown "$app:$app" "$install_dir"
    chmod u=rwx,g=rx,o= "$install_dir"
    chown -R "$app:$app" "$install_dir"/{conf,ccnet}
    chmod -R u+rwX,g+rX-w,o= "$install_dir"/{conf,ccnet}
    chown -R "$app:$app" "$seafile_image/opt/seafile"
    chmod -R u+rwX,g-w,o= "$seafile_image/opt/seafile"
    chown -R "$app:$app" "$seadoc_image/opt/sdoc-server"
    chmod -R u+rwX,g-w,o= "$seadoc_image/opt/sdoc-server"
    chown -R "$app:$app" /var/log/"$app"
    chmod -R u=rwX,g=rX,o= /var/log/"$app"

    # Allow to www-data to each dir between /opt/yunohost/seafile and /opt/yunohost/seafile/seafile_image/opt/seafile/seahub/media
    local dir_path=''
    while read -r -d/ dir_name; do
        dir_path+="$dir_name/"
        if [[ "$dir_path" == "$install_dir"* ]] && [ -e "$dir_path" ]; then
            setfacl -m user:www-data:rX "$dir_path"
        fi
    done <<< "$seafile_code/seahub/media"
    test -e "$install_dir/seafile_image/opt/seafile/seahub-data" && setfacl -m user:www-data:rX "$install_dir/seafile_image/opt/seafile/seahub-data"
    test -e "$seafile_code/seahub/media" && setfacl -R -m user:www-data:rX "$seafile_code/seahub/media"

    setfacl -m user:www-data:rX "$data_dir"
    setfacl -R -m user:www-data:rX "$data_dir"/seahub-data

    chmod u=rwx,g=rx,o= "$data_dir"
    find "$data_dir" \(   \! -perm -o= \
                     -o \! -user "$app" \
                     -o \! -group "$app" \) \
                   -exec chown "$app:$app" {} \; \
                   -exec chmod o= {} \;
}

clean_url_in_db_config() {
    sql_request='DELETE FROM `constance_config` WHERE `constance_key`= "SERVICE_URL"'
    ynh_mysql_db_shell <<< "$sql_request" --database=seahubdb
    sql_request='DELETE FROM `constance_config` WHERE `constance_key`= "FILE_SERVER_ROOT"'
    ynh_mysql_db_shell <<< "$sql_request" --database=seahubdb
}

ensure_vars_set() {
    ynh_app_setting_set_default --key=jwt_private --value=$(ynh_string_random -l 32)
    ynh_app_setting_set_default --key=protect_against_basic_auth_spoofing --value=false
}
