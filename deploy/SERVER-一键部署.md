# 服务器已登录 — 部署到独立端口 8888

网站包已打好：`deploy\release.tar.gz`（约 43MB）

预览地址将是：**http://45.76.113.226:8888/en/**

---

## 方法 A（推荐）：Windows 再开一个 PowerShell

**不要关闭** 你已登录的服务器 SSH 窗口，另开本地 PowerShell：

```powershell
cd C:\Users\Peter\Projects\weevent-website
icacls deploy\.vultr-key /inheritance:r /grant:r "$env:USERNAME`:F"
.\deploy\scripts\push-from-windows.ps1
```

完成后浏览器打开：

- http://45.76.113.226:8888/en/
- http://45.76.113.226:8888/zh/gallery/

---

## 方法 B：你正在服务器终端里操作

### 1）在 Windows 上传文件（另开 PowerShell）

```powershell
cd C:\Users\Peter\Projects\weevent-website
scp -i deploy\.vultr-key deploy\release.tar.gz root@45.76.113.226:/tmp/
scp -i deploy\.vultr-key deploy\scripts\install-port.sh root@45.76.113.226:/root/
```

### 2）回到服务器 SSH 窗口执行

```bash
bash /root/install-port.sh 8888 /tmp/weevent-release.tar.gz
```

---

## Vultr 防火墙（重要）

若浏览器打不开 8888，到 Vultr 控制台：

**Products → Firewall**（或实例 **Settings → Firewall**）

添加规则：**TCP 8888** 允许入站

---

## 换端口

```powershell
.\deploy\scripts\push-from-windows.ps1 -Port 9090
```

---

## 以后更新

```powershell
cd C:\Users\Peter\Projects\weevent-website
npm run build
tar -czf deploy\release.tar.gz -C dist .
.\deploy\scripts\push-from-windows.ps1
```
