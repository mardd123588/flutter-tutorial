# 教程站采用 VitePress 1 稳定线

教程站锁定 VitePress 1.x 的稳定版本，不跟随当前仍处于 alpha 阶段的 VitePress 2，也不使用浮动的 `@next`。首版具体使用 VitePress 1.6.4、Vue 3.5.42 和 pnpm 10.34.5，CI 使用 Node.js 22 LTS；本地允许 Node.js 22～26。首版需要的是稳定 Markdown、源码引用、本地搜索和静态部署能力；等 VitePress 2 正式发布且迁移收益明确后，再单独评估升级。
