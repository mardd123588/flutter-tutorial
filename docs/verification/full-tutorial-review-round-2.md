# 全教程第二轮总复核

> 复核日期：2026-09-01
> 基线提交：`1bf22d1`
> 范围：教程正文、源码导入、读者命令、外部参考、版本表、CI 与 Web 发布脚本。

## 复核范围

- 58 章、65 个站点页面；
- 103 处 VitePress 源码导入；
- 351 个 fenced code block；
- 站点 274 个、全仓 Markdown 657 个唯一 HTTP(S) URL 字面量；
- 13 个 Flutter 示例项目、根 Pub workspace、两份 GitHub Actions workflow 和 Node 发布工具。

外部来源的请求结果、版本对照和暂缓项见 `docs/research/full-tutorial-source-audit-round-2.md`。

## 源码引用

103 处 `<<<` 已逐项核对文件、region、语言标记和相邻讲解。导入内容都来自当前仓库源码，没有指向缺失文件或越出仓库。

内容校验器补了三层保护：无法解析的导入语法会失败；Dart、JavaScript、JSON 和 YAML 的语言标记必须匹配扩展名；region 的开始标记必须位于结束标记之前。这样能拦住“页面仍能构建，但展示了错误语言或空 region”一类回归。

## 命令与脚本

- `flutter analyze <project>` 和 `flutter test <project>/test` 已用“路线分享卡”从仓库根实跑，分析与 10 项测试通过。
- `dart run build_runner` 在 Pub workspace 中可解析；正文现已明确从对应成员目录运行，不再让读者猜生成范围。
- 第六部分不再默认加入 `--delete-conflicting-outputs`。只有确认冲突文件是旧生成物后，才按错误提示使用该参数。
- Flutter 3.47.0 工具帮助与源码确认了 `--web-define`、`--no-web-resources-cdn`、默认 Wasm dry run、`--wasm` 和已弃用的 `--pwa-strategy` 边界。
- `tool/release/smoke_staging.mjs` 实际请求 HTML、JSON，以及项目声明的 JavaScript / Wasm 资产。08-04 已删去未执行的 CSS、SVG、PNG MIME 断言，也不再把 hash fragment 写成应用路由证据。
- 受影响项目检测仍为 7 项 Node 测试，项目清单与 Pub workspace 都是 13 项。

## 外部参考

修正三条确定返回 404 的权威链接：Riverpod overrides、Apple 媒体权限和 GitHub dependency review。超时、站点防爬、私有仓库 404 和示例域名没有直接按死链处理。

早期生态调查原本用浮动 `latest` 端点证明 `freezed 4.0.0`。现在表头明确为 2026-08-29 的查阅快照，并把该版本来源固定到 4.0.0，避免后续发布让来源与数字分离。

## 版本事实

本机和仓库当前一致：Flutter 3.47.0、Dart 3.13.0、pnpm 10.34.5；本机 Node.js 26.7.0 落在 `>=22 <27` 内，CI 仍固定 Node.js 22 主版本。VitePress 1.6.4、Vue 3.5.42 与主要 Dart 包版本均和 lockfile、版本表一致，本轮不升级依赖。

Chrome 为 151.0.7922.174。教程只把具体 Chrome / ChromeDriver 数字作为当次证据，操作说明仍要求匹配当前 Chrome build，不把 151 写成长期版本合同。

## 发布前仍需完成

远程仓库当前为 private，且匿名用户还读不到 `main`。因此 13 条“项目源码”链接和 issue 链接会对匿名请求返回 404；本地路径本身都正确。首次公开发布前要么开放并推送目标提交，再逐条验收，要么删除公开页面中的仓库入口。

production Pages 尚未首次部署。本轮没有把 staging smoke、Widget 测试或本地 Chrome 结果扩大成线上 Pages、缓存更新或旧 Service Worker 注销证据。
