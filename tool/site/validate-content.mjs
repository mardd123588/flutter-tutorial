import { access, readFile, readdir } from 'node:fs/promises'
import path from 'node:path'
import process from 'node:process'

const root = process.cwd()
const siteRoot = path.join(root, 'site')
const guideRoot = path.join(siteRoot, 'guide')
const allowedKinds = new Set(['concept', 'capstone', 'focus-project'])
const allowedStatuses = new Set(['draft', 'verified'])
const conceptPattern = /^[a-z0-9]+(?:[.-][a-z0-9]+)*$/
const projectPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/
const importLanguages = new Map([
  ['.dart', 'dart'],
  ['.js', 'js'],
  ['.json', 'json'],
  ['.mjs', 'js'],
  ['.yaml', 'yaml'],
  ['.yml', 'yaml'],
])
const deprecatedTerms = [
  { pattern: /\brelease Web\b|\bRelease Web\b/, preferred: 'Web release 构建' },
  { pattern: /\bChrome integration\b/, preferred: 'Chrome 集成测试' },
  { pattern: /\bWidget test\b/, preferred: 'Widget 测试' },
  { pattern: /\bIntegration test\b/, preferred: '集成测试' },
  { pattern: /\bdeterministic golden\b/, preferred: '确定性 golden' },
  { pattern: /Chrome 关键流程/, preferred: 'Chrome 集成测试' },
  { pattern: /(?:\|\s*Unit\s*\||\bUnit\s*(?:测试|[、/]))/, preferred: '单元测试' },
  { pattern: /平台适应/, preferred: '平台适配' },
  { pattern: /导航、自适应|导航、适应/, preferred: '导航、响应式与平台适配' },
]
const errors = []

async function walk(directory, extension) {
  const entries = await readdir(directory, { withFileTypes: true })
  const files = []

  for (const entry of entries) {
    const target = path.join(directory, entry.name)
    if (entry.isDirectory()) {
      files.push(...await walk(target, extension))
    } else if (entry.isFile() && target.endsWith(extension)) {
      files.push(target)
    }
  }

  return files
}

function fail(file, message) {
  errors.push(`${path.relative(root, file)}: ${message}`)
}

function parseScalar(rawValue) {
  const value = rawValue.trim()
  if (value === '[]') return []
  if (/^\d+$/.test(value)) return Number(value)
  if (value === 'true') return true
  if (value === 'false') return false
  return value.replace(/^(['"])(.*)\1$/, '$2')
}

function parseFrontmatter(file, source) {
  if (!source.startsWith('---\n')) {
    fail(file, '缺少 YAML frontmatter')
    return { data: {}, body: source }
  }

  const end = source.indexOf('\n---\n', 4)
  if (end === -1) {
    fail(file, 'frontmatter 没有结束标记')
    return { data: {}, body: source }
  }

  const data = {}
  let activeList
  const lines = source.slice(4, end).split('\n')

  for (const line of lines) {
    const listItem = line.match(/^\s+-\s+(.+)$/)
    if (listItem && activeList) {
      data[activeList].push(parseScalar(listItem[1]))
      continue
    }

    const field = line.match(/^([a-z][a-z0-9-]*):(?:\s*(.*))?$/)
    if (!field) {
      fail(file, `无法解析 frontmatter 行：${line}`)
      activeList = undefined
      continue
    }

    const [, key, rawValue = ''] = field
    if (rawValue.trim() === '') {
      data[key] = []
      activeList = key
    } else {
      data[key] = parseScalar(rawValue)
      activeList = undefined
    }
  }

  return { data, body: source.slice(end + 5) }
}

function assertString(file, data, field) {
  if (typeof data[field] !== 'string' || data[field].trim() === '') {
    fail(file, `${field} 必须是非空字符串`)
  }
}

function assertConceptList(file, data, field) {
  if (!Array.isArray(data[field])) {
    fail(file, `${field} 必须是数组`)
    return
  }

  const seen = new Set()
  for (const concept of data[field]) {
    if (typeof concept !== 'string' || !conceptPattern.test(concept)) {
      fail(file, `${field} 包含无效概念 ID：${concept}`)
    }
    if (seen.has(concept)) {
      fail(file, `${field} 重复声明：${concept}`)
    }
    seen.add(concept)
  }
}

async function exists(target) {
  try {
    await access(target)
    return true
  } catch {
    return false
  }
}

function staysInsideRoot(target) {
  const relative = path.relative(root, target)
  return relative !== '..' && !relative.startsWith(`..${path.sep}`) && !path.isAbsolute(relative)
}

async function resolveSiteTarget(markdownFile, rawTarget) {
  const target = decodeURI(rawTarget.split(/[?#]/, 1)[0])
  if (!target) return undefined

  const base = target.startsWith('/')
    ? path.join(siteRoot, target.slice(1))
    : path.resolve(path.dirname(markdownFile), target)

  const candidates = path.extname(base)
    ? [base]
    : [base, `${base}.md`, path.join(base, 'index.md')]

  for (const candidate of candidates) {
    if (staysInsideRoot(candidate) && await exists(candidate)) return candidate
  }

  return undefined
}

async function validateLinks(file, source) {
  const links = source.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)
  for (const match of links) {
    const target = match[1].trim().replace(/^<|>$/g, '')
    if (/^(?:https?:|mailto:)/.test(target)) continue

    const [targetPath, rawFragment] = target.split('#', 2)
    const resolved = targetPath === '' ? file : await resolveSiteTarget(file, targetPath)
    if (!resolved) {
      fail(file, `内部链接不存在：${target}`)
      continue
    }

    if (rawFragment) {
      const fragment = decodeURIComponent(rawFragment)
      const targetSource = resolved === file ? source : await readFile(resolved, 'utf8')
      const escaped = fragment.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
      const explicitAnchor = new RegExp(`(?:\\{#${escaped}\\}|\\bid=["']${escaped}["'])`)
      if (!explicitAnchor.test(targetSource)) {
        fail(file, `内部锚点不存在或未显式声明：${target}`)
      }
    }
  }
}

function validateTerminology(file, source) {
  const prose = source.replace(/```[\s\S]*?```/g, '')
  for (const { pattern, preferred } of deprecatedTerms) {
    const match = prose.match(pattern)
    if (match) fail(file, `使用了旧术语“${match[0]}”，统一写作“${preferred}”`)
  }
}

async function validateImports(file, source) {
  const importLines = source.match(/^<<<.*$/gm) ?? []
  const imports = [...source.matchAll(
    /^<<<\s+([^#\s{]+)(?:#([A-Za-z0-9._-]+))?(?:\{([A-Za-z0-9_-]+)\})?\s*$/gm,
  )]
  if (imports.length !== importLines.length) {
    fail(file, '存在无法解析的源码导入语法')
  }

  for (const match of imports) {
    const target = path.resolve(path.dirname(file), match[1])
    const region = match[2]
    const language = match[3]

    if (!staysInsideRoot(target)) {
      fail(file, `源码导入越出仓库：${match[1]}`)
      continue
    }
    if (!await exists(target)) {
      fail(file, `源码导入不存在：${match[1]}`)
      continue
    }

    const expectedLanguage = importLanguages.get(path.extname(target))
    if (expectedLanguage && language !== expectedLanguage) {
      fail(
        file,
        `源码导入语言标记应为 ${expectedLanguage}：${match[1]}${language ? `{${language}}` : ''}`,
      )
    }
    if (!region) continue

    const importedSource = await readFile(target, 'utf8')
    const start = new RegExp(`(?:#|#?\\s*)region\\s+${region.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}(?:\\s|$)`)
    const end = new RegExp(`(?:#|#?\\s*)endregion\\s+${region.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}(?:\\s|$)`)
    const startMatch = importedSource.match(start)
    const endMatch = importedSource.match(end)
    if (!startMatch || !endMatch || startMatch.index >= endMatch.index) {
      fail(file, `源码 region 不完整：${match[1]}#${region}`)
    }
  }
}

const markdownFiles = await walk(siteRoot, '.md')
const chapterFiles = await walk(guideRoot, '.md')
const chapters = []

for (const file of chapterFiles) {
  const source = await readFile(file, 'utf8')
  const parsed = parseFrontmatter(file, source)
  const { data, body } = parsed

  assertString(file, data, 'title')
  assertString(file, data, 'description')
  assertConceptList(file, data, 'requires')
  assertConceptList(file, data, 'provides')

  if (!Number.isInteger(data.part) || data.part < 1) fail(file, 'part 必须是正整数')
  if (!Number.isInteger(data.order) || data.order < 1) fail(file, 'order 必须是正整数')
  if (!allowedKinds.has(data.kind)) fail(file, `kind 无效：${data.kind}`)
  if (!allowedStatuses.has(data.status)) fail(file, `status 无效：${data.status}`)
  if (data.provides?.length === 0) fail(file, 'provides 不能为空')

  const heading = body.match(/^#\s+(.+)$/m)?.[1]?.replaceAll('`', '').trim()
  if (heading !== data.title?.replaceAll('`', '').trim()) {
    fail(file, `一级标题与 title 不一致：${heading ?? '缺少一级标题'}`)
  }

  if (data.kind === 'capstone' || data.kind === 'focus-project') {
    if (typeof data.project !== 'string' || !projectPattern.test(data.project)) {
      fail(file, '项目章节必须提供有效的 project slug')
    } else {
      const group = data.kind === 'capstone' ? 'capstones' : 'focus'
      const directory = path.join(root, 'examples', group, data.project.replaceAll('-', '_'))
      if (!await exists(directory)) fail(file, `项目目录不存在：${path.relative(root, directory)}`)
    }
  } else if (data.project !== undefined) {
    fail(file, '概念章节不能声明 project')
  }

  if (data.status === 'verified') {
    const taskHeading = data.kind === 'concept' ? '## 可验证任务' : '## 项目完成检查'
    if (!body.includes(taskHeading)) fail(file, `verified 章节缺少：${taskHeading}`)
    if (!body.includes('## 复习线索')) fail(file, 'verified 章节缺少：## 复习线索')
    if (!body.includes('## 参考资料')) fail(file, 'verified 章节缺少：## 参考资料')
    if (!/（查阅：\d{4}-\d{2}-\d{2}）/.test(body)) {
      fail(file, 'verified 章节的参考资料缺少查阅日期')
    }
    if (/\b(?:TODO|TBD)\b|待补|占位内容/.test(body)) {
      fail(file, 'verified 章节仍包含占位标记')
    }
  }

  await validateImports(file, source)
  chapters.push({ file, ...data })
}

for (const file of markdownFiles) {
  const source = await readFile(file, 'utf8')
  await validateLinks(file, source)
  validateTerminology(file, source)
}

chapters.sort((left, right) => left.part - right.part || left.order - right.order)
const positions = new Set()
const providedBy = new Map()
const lastOrderByPart = new Map()

for (const chapter of chapters) {
  const position = `${chapter.part}-${chapter.order}`
  if (positions.has(position)) fail(chapter.file, `章节位置重复：${position}`)
  positions.add(position)

  const expectedOrder = (lastOrderByPart.get(chapter.part) ?? 0) + 1
  if (chapter.order !== expectedOrder) {
    fail(chapter.file, `第 ${chapter.part} 部分的 order 应为 ${expectedOrder}，实际为 ${chapter.order}`)
  }
  lastOrderByPart.set(chapter.part, chapter.order)

  for (const concept of chapter.requires ?? []) {
    if (!providedBy.has(concept)) fail(chapter.file, `requires 尚未由前序章节提供：${concept}`)
  }

  for (const concept of chapter.provides ?? []) {
    if (providedBy.has(concept)) {
      fail(chapter.file, `provides 重复；首次声明于 ${path.relative(root, providedBy.get(concept))}：${concept}`)
    } else {
      providedBy.set(concept, chapter.file)
    }
  }
}

if (errors.length > 0) {
  console.error(`内容校验失败，共 ${errors.length} 项：`)
  for (const error of errors) console.error(`- ${error}`)
  process.exitCode = 1
} else {
  console.log(`内容校验通过：${chapters.length} 章，${providedBy.size} 个概念，${markdownFiles.length} 个页面。`)
}
