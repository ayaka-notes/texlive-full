#!/usr/bin/env node
// 解析 “TeXLive Image Bug” issue 表单正文，输出 link/compiler/texlive/main
// Parse the "TeXLive Image Bug" issue form body and emit link/compiler/texlive/main.
//
// 正文从环境变量 ISSUE_BODY 读取；按 "### <标签>" 分节，依据标签里的稳定英文关键字匹配字段。
// Body is read from env ISSUE_BODY; split on "### <label>" and matched by a stable English keyword in each label.
//
// 输出 / Output (stdout, 适合写入 $GITHUB_OUTPUT / suitable for $GITHUB_OUTPUT):
//   link=...
//   compiler=auto|pdflatex|xelatex|lualatex|latex
//   texlive=auto|2026|2025|...
//   main=<path or empty>

const body = (process.env.ISSUE_BODY || '').replace(/\r/g, '')
const sections = {}
for (const chunk of body.split(/\n###\s+/)) {
  const nl = chunk.indexOf('\n')
  if (nl < 0) continue
  const heading = chunk.slice(0, nl).trim()
  let value = chunk.slice(nl + 1).trim()
  if (value === '_No response_' || value === '_无回应_') value = ''
  sections[heading] = value
}

// 按标签中的英文关键字归类 / classify by English keyword in the label
function pick(keyword) {
  for (const [h, v] of Object.entries(sections)) {
    if (h.toLowerCase().includes(keyword.toLowerCase())) return v
  }
  return ''
}

const rawLink = pick('share link')
const rawCompiler = pick('Compiler')
const rawTexlive = pick('TeX Live version')
const rawMain = pick('Main file')

// 链接：仅接受白名单格式的 overleaf.com https 链接，否则置空（由后续步骤报错）
// link: only accept an allowlisted overleaf.com https link, else empty (later step reports the error)
const linkMatch = rawLink.match(
  /https:\/\/(?:[a-z0-9-]+\.)*overleaf\.com\/(?:read\/[A-Za-z0-9]+|[A-Za-z0-9]+)(?:#[A-Za-z0-9]+)?/
)
const link = linkMatch ? linkMatch[0] : ''

// 编译器：识别已知引擎，否则 auto / compiler: recognise a known engine, else auto
let compiler = 'auto'
const cl = rawCompiler.toLowerCase()
if (cl.includes('pdflatex')) compiler = 'pdflatex'
else if (cl.includes('xelatex')) compiler = 'xelatex'
else if (cl.includes('lualatex')) compiler = 'lualatex'
else if (/\blatex\b/.test(cl) && !cl.includes('xelatex') && !cl.includes('lualatex') && !cl.includes('pdflatex'))
  compiler = 'latex'

// TeXLive 年份：取 4 位年份，否则 auto / TeX Live year: a 4-digit year, else auto
const ym = rawTexlive.match(/(20\d{2})/)
const texlive = ym ? ym[1] : 'auto'

// 主文件：取首行非空文本；若不是安全的相对 .tex 路径则置空（改为自动检测）
// main file: first non-empty line; if not a safe relative .tex path, drop it (fall back to auto-detect)
let main = (rawMain.split('\n').map(s => s.trim()).find(Boolean) || '').replace(/^`|`$/g, '')
if (main && (main.startsWith('/') || main.includes('..') || !/^[A-Za-z0-9._/ -]+\.tex$/.test(main))) {
  main = ''
}

process.stdout.write(`link=${link}\n`)
process.stdout.write(`compiler=${compiler}\n`)
process.stdout.write(`texlive=${texlive}\n`)
process.stdout.write(`main=${main}\n`)
