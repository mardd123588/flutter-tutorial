# GitHub Pages 使用 hash URL

go_router 作为生产路由方案，但 GitHub Pages 首版保留 Flutter Web 默认的 hash URL。探针验证 `/flutter-tutorial/#/details` 能直达、刷新和响应浏览器前进后退，而普通静态服务器访问 `/flutter-tutorial/details` 返回 404；只有以后愿意维护 404 回退或重写规则时，才考虑 path URL。
