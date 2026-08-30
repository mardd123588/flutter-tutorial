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
