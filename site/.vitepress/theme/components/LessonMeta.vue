<script setup lang="ts">
import { computed } from 'vue'
import { useData } from 'vitepress'

const { frontmatter } = useData()

const kindLabel = computed(() => {
  switch (frontmatter.value.kind) {
    case 'capstone':
      return '统筹项目'
    case 'focus-project':
      return '重点项目'
    default:
      return '概念章节'
  }
})
</script>

<template>
  <div class="lesson-meta" :data-kind="frontmatter.kind">
    <div class="lesson-meta__stamp">
      <span>第 {{ frontmatter.part }} 部分</span>
      <strong>{{ kindLabel }}</strong>
    </div>
    <dl>
      <div>
        <dt>需要先会</dt>
        <dd v-if="frontmatter.requires?.length">
          <code v-for="item in frontmatter.requires" :key="item">{{ item }}</code>
        </dd>
        <dd v-else>无</dd>
      </div>
      <div>
        <dt>学完获得</dt>
        <dd>
          <code v-for="item in frontmatter.provides" :key="item">{{ item }}</code>
        </dd>
      </div>
    </dl>
  </div>
</template>

