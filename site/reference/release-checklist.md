---
title: 发布清单
description: 从可复现安装到 GitHub Pages 验收和回滚的发布检查项。
---

# 发布清单

这份清单用于教程站和 13 个 Flutter Web 预览。自动化结果与人工结果分开记录；没有执行的检查保持未完成，不用相邻证据代替。

## 可复现输入

- [ ] Flutter、Dart、Node.js 与 pnpm 符合[适用版本](/reference/versions)。
- [ ] `flutter pub get` 和 `pnpm install --frozen-lockfile` 不修改 lockfile。
- [ ] 当前 commit、构建时间、`CONTENT_VERSION` 和触发方式已记录。
- [ ] `flutter analyze`、项目测试和文档检查通过。
- [ ] ChromeDriver 与当前 Chrome build 匹配，Chrome 集成测试保存失败日志和 artifact。

## 独立 Web 构建

- [ ] 每个项目使用真实 `--base-href`，不是开发服务器根路径。
- [ ] 构建参数包含 `--pwa-strategy=none` 和 `--no-web-resources-cdn`。
- [ ] `index.html` 使用正确 base，本地 CanvasKit 和声明的 Wasm、Worker 已进入产物。
- [ ] Drift 项目的 Wasm 与 Worker 文件存在，服务器返回正确 MIME。
- [ ] hash URL 可以直达和刷新；项目没有暗中依赖 Pages 的 path fallback。

## Pages staging

- [ ] VitePress 与 13 个预览合并进单一 staging，路径之间没有覆盖。
- [ ] `pnpm release:smoke` 验证 HTTP、入口、声明资源和 MIME。
- [ ] smoke 结果没有被表述成键盘、URL 历史、视觉或生产 Pages 证据。
- [ ] workflow 使用最小权限，上传的 Pages artifact 来自同一 commit。

## 人工 Web 验收

- [ ] 320×720、768×900、1440×900 三档视口没有横向溢出或任务中断。
- [ ] 200% 文本缩放保留主要内容和操作。
- [ ] 键盘可完成主任务，焦点顺序、可见焦点和弹层返回位置正确。
- [ ] Semantics、错误摘要、live region 和颜色之外的状态提示可用。
- [ ] 减少动画时没有依赖位移或时长才能理解的状态变化。
- [ ] 浏览器控制台没有未解释的 error 或 warning，网络请求没有意外第三方地址。
- [ ] Back、Forward、刷新、新标签和非法 URL 的实际行为已按项目合同检查。

## 生产发布与回滚

- [ ] production Pages 的站点入口、13 个预览和关键深链接已经首次验收。
- [ ] 缓存头和旧 Service Worker 影响已检查；必要时给用户明确清理步骤。
- [ ] 页脚、许可、隐私说明、版本页和项目状态与本次产物一致。
- [ ] 保存已发布 commit SHA、workflow run 和 artifact 标识。
- [ ] 回滚使用已知通过的 commit 重新构建，不手工拼接旧产物。

首次 production Pages 已于 2026-09-01 对提交 `6dd4fb2` 完成验收。以后每次发布仍要重新执行本清单；不能用首次发布结果替代新产物的检查。
