import { defineConfig } from 'vitepress'

const directionContract = `<!--
THESIS: Flutter knowledge is built as aligned print layers; this refuses the generic documentation hero and card grid.
OWN-WORLD: Warm paper, navy type, vermilion, teal and gold plates, registration marks, quiet body pages and action-only solid ink.
STORY: Readers see the eight-part route, start at the first available chapter, and can trace every concept to tested code and later practice.
FIRST VIEWPORT: A large course statement occupies the left half; eight offset printed sheets form the learning path on the right; the primary action sits on the front sheet.
FORM: Registration proof folio, grounded direction 3, seed 35c68d1f.
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
-->`

export default defineConfig({
  lang: 'zh-CN',
  title: 'Flutter 框架教程',
  description: '按知识依赖组织、由测试源码支撑的 Flutter 教程。',
  base: '/flutter-tutorial/',
  cleanUrls: true,
  lastUpdated: true,
  head: [
    ['link', { rel: 'icon', href: '/flutter-tutorial/favicon.svg' }],
    ['meta', { name: 'theme-color', content: '#f2ebdd' }],
  ],
  transformHtml(code) {
    return code.replace('<body>', `<body>${directionContract}`)
  },
  themeConfig: {
    logo: '/favicon.svg',
    siteTitle: 'Flutter 框架教程',
    nav: [
      { text: '顺序学习', link: '/guide/part-01/01-toolchain' },
      { text: '学习路线', link: '/reference/roadmap' },
      { text: '知识索引', link: '/reference/knowledge-index' },
      { text: '项目', link: '/projects/' },
    ],
    sidebar: {
      '/guide/': [
        {
          text: '第一部分 · 起步',
          collapsed: false,
          items: [
            { text: '把 Flutter 跑起来', link: '/guide/part-01/01-toolchain' },
            { text: 'Flutter 代码里的 Dart', link: '/guide/part-01/02-dart-in-flutter' },
            { text: 'Widget 是配置', link: '/guide/part-01/03-widget-as-configuration' },
            { text: 'build 与 BuildContext', link: '/guide/part-01/04-build-and-context' },
            { text: '够用的基础布局', link: '/guide/part-01/05-minimum-layout' },
            { text: '主题、资源与第一条测试', link: '/guide/part-01/06-theme-assets-test' },
            { text: '项目：今日节奏板', link: '/guide/part-01/07-daily-rhythm-board' },
          ],
        },
        {
          text: '第二部分 · 组件、布局与输入',
          collapsed: false,
          items: [
            { text: '约束如何决定尺寸', link: '/guide/part-02/01-constraints' },
            { text: 'Flex、Wrap、Stack 的选择', link: '/guide/part-02/02-flex-wrap-stack' },
            { text: '滚动、列表与网格', link: '/guide/part-02/03-scrolling-lists-grids' },
            { text: '可复用组件的接口', link: '/guide/part-02/04-component-interfaces' },
            { text: '文本输入、表单与验证', link: '/guide/part-02/05-text-input-and-forms' },
            { text: '手势、焦点、键盘与语义', link: '/guide/part-02/06-gestures-focus-keyboard-semantics' },
            { text: '项目：小型展览编辑器', link: '/guide/part-02/07-micro-gallery-editor' },
          ],
        },
        {
          text: '第三部分 · 状态、生命周期与动画',
          collapsed: false,
          items: [
            { text: '状态放在哪里', link: '/guide/part-03/01-state-ownership' },
            { text: '生命周期与副作用', link: '/guide/part-03/02-lifecycle-and-effects' },
            { text: 'Element 身份、Key 与重排', link: '/guide/part-03/03-keys-and-reordering' },
            { text: 'Listenable、ChangeNotifier 与 InheritedWidget', link: '/guide/part-03/04-listenable-inherited-notifier' },
            { text: '隐式动画', link: '/guide/part-03/05-implicit-animations' },
            { text: '显式动画与过渡', link: '/guide/part-03/06-explicit-animations' },
            { text: '项目：植物照护台', link: '/guide/part-03/07-plant-care-desk' },
          ],
        },
        {
          text: '第四部分 · 异步、网络与本地数据',
          collapsed: false,
          items: [
            { text: '把 Future 与 Stream 变成界面状态', link: '/guide/part-04/01-async-ui-state' },
            { text: 'HTTP Service 与错误边界', link: '/guide/part-04/02-http-service' },
            { text: '手写 JSON 模型', link: '/guide/part-04/03-hand-written-json' },
            { text: '防抖、竞态与即时书目检索', link: '/guide/part-04/04-search-race' },
            { text: 'json_serializable 与生成代码', link: '/guide/part-04/05-json-serializable' },
            { text: '偏好、缓存与离线回退', link: '/guide/part-04/06-preferences-cache-offline' },
            { text: '关系数据、Drift 与迁移', link: '/guide/part-04/07-drift-relational-data' },
            { text: '项目：城市活动雷达', link: '/guide/part-04/08-city-event-radar' },
          ],
        },
        {
          text: '第五部分 · 导航、适应、可访问性与国际化',
          collapsed: false,
          items: [
            { text: 'Navigator 与页面栈', link: '/guide/part-05/01-navigator-page-stack' },
            { text: 'Router、URL 与 go_router', link: '/guide/part-05/02-router-url-go-router' },
            { text: '深链接与路线分享卡', link: '/guide/part-05/03-deep-links-route-share-card' },
            { text: '响应式与平台适应', link: '/guide/part-05/04-responsive-adaptive' },
            { text: '可访问性作为功能', link: '/guide/part-05/05-accessibility-as-feature' },
            { text: '国际化与本地化', link: '/guide/part-05/06-internationalization-localization' },
            { text: '项目：场馆导览册', link: '/guide/part-05/07-venue-guidebook' },
          ],
        },
        {
          text: '第六部分 · 应用架构与生态主方案',
          collapsed: false,
          items: [
            { text: '复杂度从哪里出现', link: '/guide/part-06/01-complexity-signals' },
            { text: 'View、ViewModel、Repository、Service', link: '/guide/part-06/02-application-layers' },
            { text: 'Result、错误与命令', link: '/guide/part-06/03-result-command-errors' },
            { text: 'Riverpod 3 基础', link: '/guide/part-06/04-riverpod-basics' },
            { text: '异步状态、缓存失效与组合', link: '/guide/part-06/05-riverpod-async-cache' },
            { text: '依赖替换与 Riverpod 测试', link: '/guide/part-06/06-riverpod-testing' },
            { text: '代码生成、包选择与升级边界', link: '/guide/part-06/07-codegen-package-upgrades' },
            { text: '项目：社区工坊排期台', link: '/guide/part-06/08-community-workshop-scheduler' },
          ],
        },
        {
          text: '第七部分 · 测试、调试、渲染与性能',
          collapsed: false,
          items: [
            { text: '测试策略与单元测试', link: '/guide/part-07/01-test-strategy-unit' },
            { text: 'Widget、语义与视觉测试', link: '/guide/part-07/02-widget-semantics-golden' },
            { text: 'Web 浏览器关键流程', link: '/guide/part-07/03-web-integration' },
            { text: 'Widget、Element、RenderObject', link: '/guide/part-07/04-widget-element-renderobject' },
            { text: '渲染流水线与自绘边界', link: '/guide/part-07/05-rendering-pipeline' },
            { text: 'Sliver、性能分析与长卷时间轴', link: '/guide/part-07/06-sliver-performance-scroll-timeline' },
            { text: '项目：数字档案浏览器', link: '/guide/part-07/07-digital-archive-browser' },
          ],
        },
        {
          text: '第八部分 · 工程化、Web 发布与平台扩展',
          collapsed: false,
          items: [
            { text: 'Workspace、依赖与配置', link: '/guide/part-08/01-workspace-dependencies-config' },
            { text: '可复现 CI 与受影响项目', link: '/guide/part-08/02-reproducible-ci' },
            { text: 'Flutter Web release 与子路径', link: '/guide/part-08/03-flutter-web-release' },
            { text: 'GitHub Pages artifact 与发布', link: '/guide/part-08/04-github-pages-publishing' },
            { text: '平台插件、权限与平台通道', link: '/guide/part-08/05-platform-plugins-permissions-channels' },
            { text: '发布质量、隐私、许可与升级', link: '/guide/part-08/06-release-quality-privacy-upgrades' },
            { text: '项目：邻里资源交换站', link: '/guide/part-08/07-neighborhood-exchange' },
          ],
        },
      ],
      '/reference/': [
        {
          text: '参考',
          items: [
            { text: '学习路线', link: '/reference/roadmap' },
            { text: '知识索引', link: '/reference/knowledge-index' },
            { text: '适用版本', link: '/reference/versions' },
          ],
        },
      ],
    },
    outline: {
      label: '本页内容',
      level: [2, 3],
    },
    docFooter: {
      prev: '上一章',
      next: '下一章',
    },
    lastUpdated: {
      text: '最后更新',
      formatOptions: {
        dateStyle: 'medium',
      },
    },
    search: {
      provider: 'local',
      options: {
        translations: {
          button: {
            buttonText: '搜索',
            buttonAriaLabel: '搜索教程',
          },
          modal: {
            noResultsText: '没有找到相关内容',
            resetButtonTitle: '清除查询',
            footer: {
              selectText: '选择',
              navigateText: '切换',
              closeText: '关闭',
            },
          },
        },
      },
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/mardd123588/flutter-tutorial' },
    ],
    footer: {
      message: '非 Google 官方教程。Flutter 和相关标志是 Google LLC 的商标。',
      copyright: '正文与原创图示 CC BY 4.0 · 代码 BSD 3-Clause',
    },
  },
})
