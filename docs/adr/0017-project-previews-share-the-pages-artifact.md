# 项目预览与教程共用一个 GitHub Pages 产物

VitePress 发布在 `/flutter-tutorial/`，每个 Flutter Web 项目独立构建到 `/flutter-tutorial/previews/<project-slug>/`，项目内部继续使用 hash URL。发布流程先验证并构建每个项目，再把预览产物与 VitePress 产物合并成一个 GitHub Pages artifact；仓库不提交生成后的 Web 文件。

正文用截图、短录屏和独立链接引用预览，不在文章中常驻嵌入 Flutter 运行时。这样既保留可直接操作的成品，也避免多个 Flutter engine 拉高正文首屏体积、干扰键盘焦点和滚动行为。任一预览构建失败都会阻止整站发布，避免正文链接指向缺失或旧版本项目。
