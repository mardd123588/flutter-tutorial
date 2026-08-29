<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { computed } from 'vue'
import { useData } from 'vitepress'

const { Layout } = DefaultTheme
const { page, frontmatter } = useData()

const issueUrl = computed(() => {
  const params = new URLSearchParams({
    template: 'content.yml',
    title: `[内容] ${page.value.title}`,
    page: page.value.relativePath,
  })

  return `https://github.com/mardd123588/flutter-tutorial/issues/new?${params}`
})
</script>

<template>
  <Layout>
    <template #doc-before>
      <LessonMeta v-if="frontmatter.kind" />
    </template>
    <template #doc-after>
      <footer v-if="frontmatter.kind" class="lesson-footer">
        <a :href="issueUrl" target="_blank" rel="noreferrer">报告本页问题</a>
        <span>内容版本：Flutter 3.47 · Dart 3.13</span>
      </footer>
    </template>
  </Layout>
</template>

