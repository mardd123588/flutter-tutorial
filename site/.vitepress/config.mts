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
