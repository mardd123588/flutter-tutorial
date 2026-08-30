<script setup lang="ts">
import { withBase } from 'vitepress'

const parts = [
  { number: '01', title: '起步与 Flutter 所需 Dart', detail: '7 章 · 当前可学', href: '/guide/part-01/01-toolchain', ink: 'navy', available: true },
  { number: '02', title: '组件、布局与输入', detail: '7 章 · 当前可学', href: '/guide/part-02/01-constraints', ink: 'vermillion', available: true },
  { number: '03', title: '状态、生命周期与动画', detail: '7 章 · 当前可学', href: '/guide/part-03/01-state-ownership', ink: 'teal', available: true },
  { number: '04', title: '异步、网络与本地数据', detail: '规划 8 章', href: '/reference/roadmap#part-04', ink: 'gold' },
  { number: '05', title: '导航、自适应、可访问性与国际化', detail: '规划 7 章', href: '/reference/roadmap#part-05', ink: 'navy' },
  { number: '06', title: '应用架构与生态主方案', detail: '规划 8 章', href: '/reference/roadmap#part-06', ink: 'vermillion' },
  { number: '07', title: '测试、调试、渲染与性能', detail: '规划 7 章', href: '/reference/roadmap#part-07', ink: 'teal' },
  { number: '08', title: '工程化、Web 发布与平台扩展', detail: '规划 7 章', href: '/reference/roadmap#part-08', ink: 'gold' },
]
</script>

<template>
  <main class="home-page">
    <section class="proof-hero" aria-labelledby="home-title">
      <div class="proof-hero__copy">
        <p class="proof-meta">
          <span>Flutter 3.47 · Dart 3.13</span>
          <span>当前内容：7 章 · 1 个 Web 验收项目</span>
          <span>首版规划：58 章 · 13 个项目</span>
        </p>
        <h1 id="home-title">把 Flutter 学成一套能解释、能验证的框架知识</h1>
        <p class="proof-lead">
          先看机制，再写代码。每章声明知识前置，示例来自通过测试的源码；每个部分用一个独立项目把知识重新用一遍。
        </p>
        <div class="proof-actions">
          <a class="proof-action" :href="withBase('/reference/knowledge-index')">按知识点复习</a>
          <a class="proof-action" :href="withBase('/projects/')">查看项目与测试状态</a>
        </div>
        <p class="proof-note">适合已经会 Dart，并接触过其他编程语言的读者。</p>
      </div>

      <ol class="plate-stack" aria-label="八个学习部分">
        <li v-for="(part, index) in parts" :key="part.number" :class="['plate', `plate--${part.ink}`, { 'plate--available': part.available }]" :style="{ '--plate-index': index }">
          <a class="plate__link" :href="withBase(part.href)">
            <span class="plate__number">{{ part.number }}</span>
            <span class="plate__copy">
              <strong>{{ part.title }}</strong>
              <small>{{ part.detail }}</small>
            </span>
            <span v-if="part.available" class="plate__action">进入本部分 <span aria-hidden="true">→</span></span>
            <span class="plate__overprint" aria-hidden="true"></span>
          </a>
        </li>
      </ol>
    </section>

    <section class="proof-system" aria-labelledby="system-title">
      <div class="proof-system__intro">
        <h2 id="system-title">知识会对齐，代码也要对齐</h2>
        <p>章节顺序不是目录编辑出来的。`requires` 与 `provides` 组成依赖图，源码 region、测试和页面引用在构建时一起检查。</p>
      </div>
      <div class="registration-example" aria-label="知识依赖示例">
        <div class="registration-layer registration-layer--navy">
          <span>requires</span>
          <strong>layout.constraints</strong>
        </div>
        <div class="registration-layer registration-layer--vermillion">
          <span>chapter</span>
          <strong>Flex、Wrap、Stack</strong>
        </div>
        <div class="registration-layer registration-layer--teal">
          <span>provides</span>
          <strong>layout.flex</strong>
        </div>
        <div class="registration-mark" aria-hidden="true"></div>
      </div>
    </section>

    <section class="proof-promises" aria-label="教程的三个约束">
      <article>
        <h2>难点讲到能排错</h2>
        <p>约束、BuildContext、状态身份、异步竞态、路由、渲染和性能都会解释运行机制与错误现象。</p>
      </article>
      <article>
        <h2>项目不拆成连续剧</h2>
        <p>一个项目只在一章中完整讲完。源码和独立预览可以随时打开，不依赖前一个项目。</p>
      </article>
      <article>
        <h2>Web 验收不冒充全平台</h2>
        <p>所有项目在 Chrome 中测试并构建 release Web；原生权限、通知和平台通道单独说明验证边界。</p>
      </article>
    </section>
  </main>
</template>
