# 持久化方案按数据形态选择

少量设置使用 `SharedPreferencesAsync`，关系查询、迁移与响应式数据使用 Drift，不把一个存储包套到所有项目。Drift 项目携带匹配版本的 `sqlite3.wasm` 与 `drift_worker.js`，并验证 MIME、浏览器能力回退、刷新和多标签页；探针在缺少 SharedArrayBuffer 时回退到 Shared IndexedDB，仍能保持数据。
