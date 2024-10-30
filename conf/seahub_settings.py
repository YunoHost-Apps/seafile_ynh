# -*- coding: utf-8 -*-

# WARNING: Don't edit this file. All change will be removed after each app upgrade

SECRET_KEY = "{{ seahub_secret_key }}"

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'seahubdb',
        'USER': '{{ db_user }}',
        'PASSWORD': '{{ db_pwd }}',
        'HOST': '127.0.0.1',
        'PORT': '3306',
        'OPTIONS': {'charset': 'utf8mb4'},
    }
}

CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': '127.0.0.1:11211',
    },
}

FILE_SERVER_ROOT = "https://{{ domain }}/seafhttp"
SERVE_STATIC = False
MEDIA_URL = "{{ path2 }}media/"
COMPRESS_URL = MEDIA_URL
STATIC_URL = MEDIA_URL + 'assets/'
LOGIN_URL = '{{ path2 }}accounts/login/'

#
# LDAP
#

ENABLE_LDAP = True
# The URL of LDAP server
LDAP_SERVER_URL = 'ldap://localhost:389'

# The root node of users who can log in to Seafile in the LDAP server
LDAP_BASE_DN = 'ou=users,dc=yunohost,dc=org'

# DN of the administrator used to query the LDAP server for information.
# For OpenLDAP, it maybe cn=admin,dc=example,dc=com
LDAP_ADMIN_DN = '' # Need to leave empty to work with anonymous authentication

# Password of LDAP_ADMIN_DN
LDAP_ADMIN_PASSWORD = '' # Need to leave empty to work with anonymous authentication

# Identify the source of the user, used in
# the table social_auth_usersocialauth, defaults to 'ldap'
LDAP_PROVIDER = 'ldap'

# User's attribute used to log in to Seafile.
# It should be a unique identifier for the user in LDAP server.
# Learn more about this id from the descriptions at begining of this section.
LDAP_LOGIN_ATTR = 'mail'

# LDAP user's contact_email attribute
LDAP_CONTACT_EMAIL_ATTR = 'mail'

# LDAP user's role attribute
LDAP_USER_ROLE_ATTR = ''

# For sync user's first name
LDAP_USER_FIRST_NAME_ATTR = 'givenName'

# For sync user's last name
LDAP_USER_LAST_NAME_ATTR = 'sn'

# Whether to reverse the user's first and last name
LDAP_USER_NAME_REVERSE = False

# Additional filter conditions, users who meet the filter conditions can log in, otherwise they cannot log in
LDAP_FILTER = 'permission=cn={{ app }}.main,ou=permission,dc=yunohost,dc=org'

#
# SSO
#

ENABLE_REMOTE_USER_AUTHENTICATION = True

# Optional, HTTP header, which is configured in your web server conf file,
# used for Seafile to get user's unique id, default value is 'HTTP_REMOTE_USER'.
REMOTE_USER_HEADER = 'HTTP_YNH_USER_EMAIL'

# Optional, when the value of HTTP_REMOTE_USER is not a valid email address，
# Seafile will build a email-like unique id from the value of 'REMOTE_USER_HEADER'
# and this domain, e.g. user1@example.com.
# REMOTE_USER_DOMAIN = 'example.com'

# Optional, whether to create new user in Seafile system, default value is True.
# If this setting is disabled, users doesn't preexist in the Seafile DB cannot login.
# The admin has to first import the users from external systems like LDAP.
REMOTE_USER_CREATE_UNKNOWN_USER = False

# Optional, whether to activate new user in Seafile system, default value is True.
# If this setting is disabled, user will be unable to login by default.
# the administrator needs to manually activate this user.
# REMOTE_USER_ACTIVATE_USER_AFTER_CREATION = True

# Optional, map user attribute in HTTP header and Seafile's user attribute.
# REMOTE_USER_ATTRIBUTE_MAP = {
#     'HTTP_DISPLAYNAME': 'name',
#     'HTTP_EMAIL': 'contact_email',
#
#     # for user info
#     "HTTP_GIVENNAME": 'givenname',
#     "HTTP_SN": 'surname',
# }
REMOTE_USER_PROTECTED_PATH = ['{{ path }}', '{{ path2 }}accounts/login', '{{ path2 }}sso']
REMOTE_USER_IMPORT_FROM_LDAP = True

#
# Security settings
#

# For security consideration, please set to match the host/domain of your site, e.g., ALLOWED_HOSTS = ['.example.com'].
# Please refer https://docs.djangoproject.com/en/dev/ref/settings/#allowed-hosts for details.
ALLOWED_HOSTS = ['{{ domain }}']

# Whether to use a secure cookie for the CSRF cookie
# https://docs.djangoproject.com/en/3.2/ref/settings/#csrf-cookie-secure
CSRF_COOKIE_SECURE = True

# The value of the SameSite flag on the CSRF cookie
# https://docs.djangoproject.com/en/3.2/ref/settings/#csrf-cookie-samesite
CSRF_COOKIE_SAMESITE = 'Strict'

# https://docs.djangoproject.com/en/3.2/ref/settings/#csrf-trusted-origins
CSRF_TRUSTED_ORIGINS = ['https://{{ domain }}']

#
# User options
#

# Enalbe or disalbe registration on web. Default is `False`.
# ENABLE_SIGNUP = False

# Activate or deactivate user when registration complete. Default is `True`.
# If set to `False`, new users need to be activated by admin in admin panel.
# ACTIVATE_AFTER_REGISTRATION = True

# Whether to send email when a system admin adding a new member. Default is `True`.
# SEND_EMAIL_ON_ADDING_SYSTEM_MEMBER = True

# Whether to send email when a system admin resetting a user's password. Default is `True`.
# SEND_EMAIL_ON_RESETTING_USER_PASSWD = True

# Send system admin notify email when user registration is complete. Default is `False`.
# NOTIFY_ADMIN_AFTER_REGISTRATION = False

# Remember days for login. Default is 7
# LOGIN_REMEMBER_DAYS = 7

# Attempt limit before showing a captcha when login.
# LOGIN_ATTEMPT_LIMIT = 3

# deactivate user account when login attempts exceed limit
# Since version 5.1.2 or pro 5.1.3
# FREEZE_USER_ON_LOGIN_FAILED = False

# Age of cookie, in seconds (default: 2 weeks).
# SESSION_COOKIE_AGE = 60 * 60 * 24 * 7 * 2

# Whether a user's session cookie expires when the Web browser is closed.
# SESSION_EXPIRE_AT_BROWSER_CLOSE = False

# Whether to save the session data on every request. Default is `False`
# SESSION_SAVE_EVERY_REQUEST = False

# Whether enable the feature "published library". Default is `False`
# Since 6.1.0 CE
ENABLE_WIKI = True

# In old version, if you use Single Sign On, the password is not saved in Seafile.
# Users can't use WebDAV because Seafile can't check whether the password is correct.
# Since version 6.3.8, you can enable this option to let user's to specific a password for WebDAV login.
# Users login via SSO can use this password to login in WebDAV.
# Enable the feature. pycryptodome should be installed first.
# sudo pip install pycryptodome==3.12.0
ENABLE_WEBDAV_SECRET = False

# Since version 7.0.9, you can force a full user to log in with a two factor authentication.
# The prerequisite is that the administrator should 'enable two factor authentication' in the 'System Admin -> Settings' page.
# Then you can add the following configuration information to the configuration file.
# ENABLE_FORCE_2FA_TO_ALL_USERS = False

#
# Library options
#

# if enable create encrypted library
# ENABLE_ENCRYPTED_LIBRARY = True

# version for encrypted library
# should only be `2` or `4`.
# version 3 is insecure (using AES128 encryption) so it's not recommended any more.
# ENCRYPTED_LIBRARY_VERSION = 2

# mininum length for password of encrypted library
# REPO_PASSWORD_MIN_LENGTH = 8

# force use password when generate a share/upload link (since version 8.0.9)
# SHARE_LINK_FORCE_USE_PASSWORD = False

# mininum length for password for share link (since version 4.4)
# SHARE_LINK_PASSWORD_MIN_LENGTH = 8

# LEVEL for the password of a share/upload link
# based on four types of input:
# num, upper letter, lower letter, other symbols
# '3' means password must have at least 3 types of the above. (since version 8.0.9)
# SHARE_LINK_PASSWORD_STRENGTH_LEVEL = 3

# Default expire days for share link (since version 6.3.8)
# Once this value is configured, the user can no longer generate an share link with no expiration time.
# If the expiration value is not set when the share link is generated, the value configured here will be used.
# SHARE_LINK_EXPIRE_DAYS_DEFAULT = 5

# minimum expire days for share link (since version 6.3.6)
# SHARE_LINK_EXPIRE_DAYS_MIN should be less than SHARE_LINK_EXPIRE_DAYS_DEFAULT (If the latter is set).
# SHARE_LINK_EXPIRE_DAYS_MIN = 3 # default is 0, no limit.

# maximum expire days for share link (since version 6.3.6)
# SHARE_LINK_EXPIRE_DAYS_MIN should be greater than SHARE_LINK_EXPIRE_DAYS_DEFAULT (If the latter is set).
# SHARE_LINK_EXPIRE_DAYS_MAX = 8 # default is 0, no limit.

# Default expire days for upload link (since version 7.1.6)
# Once this value is configured, the user can no longer generate an upload link with no expiration time.
# If the expiration value is not set when the upload link is generated, the value configured here will be used.
# UPLOAD_LINK_EXPIRE_DAYS_DEFAULT = 5

# minimum expire days for upload link (since version 7.1.6)
# UPLOAD_LINK_EXPIRE_DAYS_MIN should be less than UPLOAD_LINK_EXPIRE_DAYS_DEFAULT (If the latter is set).
# UPLOAD_LINK_EXPIRE_DAYS_MIN = 3 # default is 0, no limit.

# maximum expire days for upload link (since version 7.1.6)
# UPLOAD_LINK_EXPIRE_DAYS_MAX should be greater than UPLOAD_LINK_EXPIRE_DAYS_DEFAULT (If the latter is set).
# UPLOAD_LINK_EXPIRE_DAYS_MAX = 8 # default is 0, no limit.

# force user login when view file/folder share link (since version 6.3.6)
# SHARE_LINK_LOGIN_REQUIRED = False

# enable water mark when view(not edit) file in web browser (since version 6.3.6)
# ENABLE_WATERMARK = True

# Disable sync with any folder. Default is `False`
# NOTE: since version 4.2.4
# DISABLE_SYNC_WITH_ANY_FOLDER = False

# Enable or disable library history setting
# ENABLE_REPO_HISTORY_SETTING = True

# Enable or disable normal user to create organization libraries
# Since version 5.0.5
# ENABLE_USER_CREATE_ORG_REPO = True

# Enable or disable user share library to any group
# Since version 6.2.0
# ENABLE_SHARE_TO_ALL_GROUPS = True

# Enable or disable user to clean trash (default is True)
# Since version 6.3.6
# ENABLE_USER_CLEAN_TRASH = True

# Add a report abuse button on download links. (since version 7.1.0)
# Users can report abuse on the share link page, fill in the report type, contact information, and description.
# Default is false.
# ENABLE_SHARE_LINK_REPORT_ABUSE = False

#
# Online preview
#

# Whether to use pdf.js to view pdf files online. Default is `True`,  you can turn it off.
# NOTE: since version 1.4.
# USE_PDFJS = True

# Online preview maximum file size, defaults to 30M.
# FILE_PREVIEW_MAX_SIZE = 30 * 1024 * 1024

# Extensions of previewed text files.
# NOTE: since version 6.1.1
# TEXT_PREVIEW_EXT = """ac, am, bat, c, cc, cmake, cpp, cs, css, diff, el, h, html,
# htm, java, js, json, less, make, org, php, pl, properties, py, rb,
# scala, script, sh, sql, txt, text, tex, vi, vim, xhtml, xml, log, csv,
# groovy, rst, patch, go"""

# Enable or disable thumbnails
# NOTE: since version 4.0.2
# ENABLE_THUMBNAIL = True

# Seafile only generates thumbnails for images smaller than the following size.
# Since version 6.3.8 pro, suport the psd online preview.
# THUMBNAIL_IMAGE_SIZE_LIMIT = 30 # MB

# Enable or disable thumbnail for video. ffmpeg and moviepy should be installed first.
# For details, please refer to https://manual.seafile.com/deploy/video_thumbnails.html
# NOTE: this option is deprecated in version 7.1
# ENABLE_VIDEO_THUMBNAIL = False

# Use the frame at 5 second as thumbnail
# NOTE: this option is deprecated in version 7.1
# THUMBNAIL_VIDEO_FRAME_TIME = 5

# Absolute filesystem path to the directory that will hold thumbnail files.
# THUMBNAIL_ROOT = '/haiwen/seahub-data/thumbnail/thumb/'

# Default size for picture preview. Enlarge this size can improve the preview quality.
# NOTE: since version 6.1.1
# THUMBNAIL_SIZE_FOR_ORIGINAL = 1024

#
# Other options
#

# This is outside URL for Seahub(Seafile Web).
# The domain part (i.e., www.example.com) will be used in generating share links and download/upload file via web.
# Note: Outside URL means "if you use Nginx, it should be the Nginx's address"
# Note: SERVICE_URL is moved to seahub_settings.py since 9.0.0
SERVICE_URL =  "https://{{ domain }}{{ path }}"

# Disable settings via Web interface in system admin->settings
# Default is True
# Since 5.1.3
# ENABLE_SETTINGS_VIA_WEB = True

# Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = "{{ time_zone }}"

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
# Default language for sending emails.
LANGUAGE_CODE = '{{ language }}'

# Custom language code choice.
# LANGUAGES = ( )

# Set this to your website/company's name. This is contained in email notifications and welcome message when user login for the first time.
SITE_NAME = 'Seafile'

# Browser tab's title
SITE_TITLE = 'Private Seafile'

# If you don't want to run seahub website on your site's root path, set this option to your preferred path.
# e.g. setting it to '/seahub/' would run seahub on http://example.com/seahub/.
SITE_ROOT = "{{ path2 }}"

# Max number of files when user upload file/folder.
# Since version 6.0.4
# MAX_NUMBER_OF_FILES_FOR_FILEUPLOAD = 500

# Control the language that send email. Default to user's current language.
# Since version 6.1.1
# SHARE_LINK_EMAIL_LANGUAGE = ''

# Interval for browser requests unread notifications
# Since PRO 6.1.4 or CE 6.1.2
# UNREAD_NOTIFICATIONS_REQUEST_INTERVAL = 3 * 60 # seconds

# Get web api auth token on profile page.
# ENABLE_GET_AUTH_TOKEN_BY_SESSION = True

# Since 8.0.6 CE/PRO version.
# Url redirected to after user logout Seafile.
# Usually configured as Single Logout url.
LOGOUT_REDIRECT_URL = 'https://{{ domain }}/yunohost/sso/?action=logout'

# Enable system admin add T&C, all users need to accept terms before using. Defaults to `False`.
# Since version 6.0
# ENABLE_TERMS_AND_CONDITIONS = False

# Enable two factor authentication for accounts. Defaults to `False`.
# Since version 6.0
# ENABLE_TWO_FACTOR_AUTH = False

# Enable user select a template when he/she creates library.
# When user select a template, Seafile will create folders releated to the pattern automaticly.
# Since version 6.0
# LIBRARY_TEMPLATES = {
#     'Technology': ['/Develop/Python', '/Test'],
#     'Finance': ['/Current assets', '/Fixed assets/Computer']
# }

# Enable a user to change password in 'settings' page. Default to `True`
# Since version 6.2.11
# ENABLE_CHANGE_PASSWORD = True

# If show contact email when search user.
# ENABLE_SHOW_CONTACT_EMAIL_WHEN_SEARCH_USER = True

#
# Mail
#

EMAIL_USE_TLS = True
EMAIL_HOST = "{{ domain }}"
EMAIL_HOST_USER = "{{ app }}"
EMAIL_HOST_PASSWORD = "{{ mail_pwd }}"
EMAIL_PORT = "587"
REPLACE_FROM_EMAIL = True
ADD_REPLY_TO_HEADER = True
DEFAULT_FROM_EMAIL = "{{ app }}@{{ domain }}"
SERVER_EMAIL = "{{ app }}@{{ domain }}"

#
# RESTful API
#

# API throttling related settings. Enlarger the rates if you got 429 response code during API calls.
# REST_FRAMEWORK = {
#     'DEFAULT_THROTTLE_RATES': {
#         'ping': '600/minute',
#         'anon': '5/minute',
#         'user': '300/minute',
#     },
#     'UNICODE_JSON': False,
# }

# Throtting whitelist used to disable throttle for certain IPs.
# e.g. REST_FRAMEWORK_THROTTING_WHITELIST = ['127.0.0.1', '192.168.1.1']
# Please make sure `REMOTE_ADDR` header is configured in Nginx conf according to https://manual.seafile.com/deploy/deploy_with_nginx.html.
# REST_FRAMEWORK_THROTTING_WHITELIST = []
