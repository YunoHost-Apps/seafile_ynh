source /usr/share/yunohost/helpers

#=================================================
# SET ALL CONSTANTS
#=================================================

readonly seafile_version=$(ynh_app_upstream_version)

readonly seafile_image="$install_dir/seafile_image"
readonly notification_image="$install_dir/notification_image"
readonly seafile_code="$seafile_image/opt/seafile/seafile-server-$seafile_version"

readonly time_zone="$(cat /etc/timezone)"
readonly python_version="$(python3 -V | cut -d' ' -f2 | cut -d. -f1-2)"
systemd_seafile_bind_mount="$data_dir/seafile-data:/opt/seafile/seafile-data "
systemd_seafile_bind_mount+="$data_dir/seahub-data:/opt/seafile/seahub-data "
systemd_seafile_bind_mount+="/var/log/$app:/opt/seafile/logs "
systemd_seafile_bind_mount+="$install_dir/conf:/opt/seafile/conf "
systemd_seafile_bind_mount+="$install_dir/ccnet:/opt/seafile/ccnet "
systemd_seafile_bind_mount+="/proc "
systemd_seafile_bind_mount+="/dev"

systemd_notification_server_bind_mount="$data_dir/notification-data:/opt/notification-data "
systemd_notification_server_bind_mount+="/proc "
systemd_notification_server_bind_mount+="/dev"

# Create special path with / at the end
if [[ "$path" == '/' ]]
then
    readonly path2="$path"
else
    readonly path2="$path/"
fi

if [ "${LANG:0:2}" == C. ]; then
    readonly language=en
else
    readonly language="${LANG:0:2}"
fi

#=================================================
# DEFINE ALL COMMON FONCTIONS
#=================================================

run_seafile_cmd() {
    ynh_hide_warnings systemd-run --wait --pty --uid="$app" --gid="$app" \
        --property=RootDirectory="$install_dir"/seafile_image \
        --property="BindPaths=$systemd_seafile_bind_mount" \
        --property=EnvironmentFile="$install_dir"/seafile_env.conf \
        "$@"
}

install_source() {
    # set correct seafile version in patch
    ynh_replace --match="__SEAFILE_VERSION__" --replace="$seafile_version" --file="$YNH_APP_BASEDIR"/patches/main/import_ldap_user_when_authenticated_from_remoteUserBackend.patch
    ynh_setup_source_custom --dest_dir="$seafile_image" --full_replace
    mkdir -p "$install_dir"/seafile_image/opt/seafile/{seafile-data,seahub-data,conf,ccnet,logs}
    grep "^$app:x"  /etc/passwd | sed "s|$install_dir|/opt/seafile|" >> "$install_dir"/seafile_image/etc/passwd
    grep "^$app:x"  /etc/group >> "$install_dir"/seafile_image/etc/group
    grep "^$app:x"  /etc/group- >> "$install_dir"/seafile_image/etc/group-
    grep "^$app:"  /etc/shadow >> "$install_dir"/seafile_image/etc/shadow

    ynh_setup_source_custom --dest_dir="$notification_image" --full_replace --source_id=notification_server
    grep "^$app:x"  /etc/passwd | sed "s|$install_dir|/opt/seafile|" >> "$install_dir"/seafile_image/etc/passwd
    grep "^$app:x"  /etc/group >> "$install_dir"/seafile_image/etc/group
    grep "^$app:x"  /etc/group- >> "$install_dir"/seafile_image/etc/group-
    grep "^$app:"  /etc/shadow >> "$install_dir"/seafile_image/etc/shadow
}

set_permission() {
    chown "$app:$app" "$install_dir"
    chmod u=rwx,g=rx,o= "$install_dir"
    chown -R "$app:$app" "$install_dir"/{conf,ccnet}
    chmod -R u+rwX,g+rX-w,o= "$install_dir"/{conf,ccnet}
    chown -R "$app:$app" "$install_dir"/seafile_image/opt/seafile
    chmod -R u+rwX,g-w,o= "$install_dir"/seafile_image/opt/seafile
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

    # At install time theses directory are not available
    test -e "$install_dir"/seahub-data && setfacl -m user:www-data:rX "$data_dir"
    test -e "$install_dir"/seahub-data && setfacl -R -m user:www-data:rX "$data_dir"/seahub-data

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
