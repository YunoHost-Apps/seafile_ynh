<!--
注意：此 README 由 <https://github.com/YunoHost/apps/tree/master/tools/readme_generator> 自动生成
请勿手动编辑。
-->

# YunoHost 的 Seafile

[![集成程度](https://dash.yunohost.org/integration/seafile.svg)](https://dash.yunohost.org/appci/app/seafile) ![工作状态](https://ci-apps.yunohost.org/ci/badges/seafile.status.svg) ![维护状态](https://ci-apps.yunohost.org/ci/badges/seafile.maintain.svg)

[![使用 YunoHost 安装 Seafile](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=seafile)

*[阅读此 README 的其它语言版本。](./ALL_README.md)*

> *通过此软件包，您可以在 YunoHost 服务器上快速、简单地安装 Seafile。*  
> *如果您还没有 YunoHost，请参阅[指南](https://yunohost.org/install)了解如何安装它。*

## 概况

Seafile is an open Source Cloud Storage application.

It's a Enterprise file sync and share platform with high reliability and performance. It's a file hosting platform with high reliability and performance. Put files on your own server. Sync and share files across different devices, or access all the files as a virtual disk.


**分发版本：** 11.0.6~ynh1

**演示：** <https://demo.seafile.com>

## 截图

![Seafile 的截图](./doc/screenshots/mobile-ios-client.jpg)
![Seafile 的截图](./doc/screenshots/drive-client.png)
![Seafile 的截图](./doc/screenshots/file-locking.jpg)
![Seafile 的截图](./doc/screenshots/access-logs.jpg)
![Seafile 的截图](./doc/screenshots/file-history.png)
![Seafile 的截图](./doc/screenshots/wiki_en.png)
![Seafile 的截图](./doc/screenshots/sharing-dialog.png)
![Seafile 的截图](./doc/screenshots/sync-client.jpg)

## 文档与资源

- 官方应用网站： <https://www.seafile.com>
- 官方管理文档： <https://manual.seafile.com>
- 上游应用代码库： <https://github.com/haiwen/seafile-server>
- YunoHost 商店： <https://apps.yunohost.org/app/seafile>
- 报告 bug： <https://github.com/YunoHost-Apps/seafile_ynh/issues>

## 开发者信息

请向 [`testing` 分支](https://github.com/YunoHost-Apps/seafile_ynh/tree/testing) 发送拉取请求。

如要尝试 `testing` 分支，请这样操作：

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/seafile_ynh/tree/testing --debug
或
sudo yunohost app upgrade seafile -u https://github.com/YunoHost-Apps/seafile_ynh/tree/testing --debug
```

**有关应用打包的更多信息：** <https://yunohost.org/packaging_apps>
