# GitHub 发布与客户预览

## 客户预览地址（部署后）

```
https://你的用户名.github.io/weevent-website/en/
https://你的用户名.github.io/weevent-website/zh/
```

## 首次：连接 GitHub 账户

在 PowerShell 执行：

```powershell
gh auth login
```

按提示选择：
1. **GitHub.com**
2. **HTTPS**
3. **Login with a web browser**（浏览器登录）
4. 复制一次性代码到浏览器完成授权

## 上传并发布

```powershell
cd C:\Users\Peter\Projects\weevent-website
.\deploy\scripts\publish-github.ps1
```

## 开启 GitHub Pages

首次推送后，在 GitHub 仓库页面：

**Settings → Pages → Build and deployment → Source: GitHub Actions**

推送 `main` 分支后约 1–2 分钟自动部署。

## 更新网站给客户看

改完代码后：

```powershell
git add -A
git commit -m "update content"
git push
```

GitHub Actions 会自动重新发布。
