# Vultr 部署指南（中文）

## 已为你准备好的内容

- `deploy/scripts/setup-vultr.sh` — 服务器一次性配置（Nginx + 防火墙）
- `deploy/scripts/deploy.ps1` — 构建并上传网站到 Vultr
- `deploy/scripts/setup-and-deploy.ps1` — 一键：配置服务器 + 发布网站
- `deploy/config.env` — 服务器 IP 等（已 gitignore，不会提交）

## 你的 Vultr 服务器

根据本机 SSH 记录，IP 为：**45.76.113.226**（已写入 `deploy/config.env`）

## 第一步：确认能 SSH 登录

在 PowerShell 执行：

```powershell
ssh root@45.76.113.226
```

若提示 `Permission denied`，需要：

1. 在 Vultr 控制台 → 你的实例 → **Settings** → 确认已添加你的 **SSH Public Key**
2. 或重置 root 密码，用密码登录一次

## 第二步：SSH 密钥

私钥已保存到 `deploy\.vultr-key`（不会提交到 Git）。

**安全提示**：私钥曾在聊天中发送，部署完成后建议在 Vultr 控制台**删除并重新生成** SSH 密钥。

```powershell
icacls deploy\.vultr-key /inheritance:r /grant:r "$env:USERNAME`:F"
ssh -i deploy\.vultr-key root@45.76.113.226
```

## 第三步：一键部署

在你本机 PowerShell 执行（需能 SSH 登录）：

```powershell
cd C:\Users\Peter\Projects\weevent-website
node deploy\scripts\deploy-remote.mjs
```

或：

```powershell
.\deploy\scripts\setup-and-deploy.ps1
```

成功后访问：

- http://45.76.113.226/en/
- http://45.76.113.226/zh/gallery/

## 第四步：域名 DNS

在域名管理（we-events.co.nz）添加：

| 类型 | 主机 | 值 |
|------|------|-----|
| A | @ | 45.76.113.226 |
| A | www | 45.76.113.226 |

## 第五步：开启 HTTPS

DNS 生效后（约 5–30 分钟）：

```powershell
ssh root@45.76.113.226 "certbot --nginx -d we-events.co.nz -d www.we-events.co.nz --email joy@we-events.co.nz --agree-tos --no-eff-email --redirect"
```

正式地址：https://www.we-events.co.nz/en/

## 以后更新网站

改完代码后：

```powershell
.\deploy\scripts\deploy.ps1
```
