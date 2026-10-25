# GitHub 发布说明

仓库已经整理成可以直接推送的 `main` 分支，历史提交在本地 `main-history` 备份分支中。

## 推荐仓库信息

- Repository name：`nailong-protocol`
- Description：`NAILONG PROTOCOL: 8AM BOTANICA — local-LLM-directed, YOLO-observed absurdist tower defense`
- Topics：`typescript` `vite` `canvas` `fastapi` `yolo` `local-llm` `tower-defense` `game-development` `qwen`

## 创建并推送

先在 GitHub 网页新建一个空仓库（不要勾选自动生成 README、.gitignore 或 LICENSE），然后在本目录执行：

```powershell
git remote add origin https://github.com/<你的用户名>/nailong-protocol.git
git push -u origin main
git push origin v3.1.0
```

如果已经有 origin：

```powershell
git remote set-url origin https://github.com/<你的用户名>/nailong-protocol.git
git push -u origin main
```

## 版本标签

本地已创建 `v3.1.0` 标签；推送时加 `--tags`：

```powershell
git push origin main --tags
```

## GitHub Actions

`.github/workflows/ci.yml` 会在 push / PR 时执行：

- TypeScript 类型检查 + Vite 构建
- Python 后端与脚本语法编译

CI 不下载 YOLO 权重，也不跑摄像头 E2E，避免每次构建都装 CUDA/PyTorch。

## 大文件

仓库里保留了：

- `models/abstract_yolo.pt`（约 5MB）
- `models/yolo11n.pt`（约 5MB）
- `demo/` 宣传截图（约 40MB）

都低于 GitHub 单文件 100MB 限制，可以直接普通 Git 推送，不需要 LFS。

如果只想提交纯代码，可以在推送前把 `models/*.pt` 和 `demo/*.png` 从索引中移除，但 README 的预览图会失效。
