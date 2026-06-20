#!/usr/bin/env node
// 从 Overleaf 分享链接抓取项目（下载 zip + 尽力探测编译器/TeXLive 版本）
// Fetch an Overleaf project from a share link (download zip + best-effort detect compiler / TeX Live version).
//
// 用法 / Usage:
//   node overleaf-fetch.mjs --link <share-url> --zip <out.zip> --meta <out.json>
//
// 仅依赖 Node 内置 fetch；socket 探测可选依赖 ws（缺失时自动跳过）。
// Only depends on Node's built-in fetch; the socket probe optionally uses `ws` (skipped if absent).

import { writeFileSync } from 'node:fs'

// ---- 解析命令行参数 / parse CLI args ----
const args = {}
for (let i = 2; i < process.argv.length; i++) {
  const a = process.argv[i]
  if (a.startsWith('--')) args[a.slice(2)] = process.argv[++i]
}
const link = args.link
const zipOut = args.zip || 'project.zip'
const metaOut = args.meta || 'meta.json'
if (!link) {
  console.error('错误：必须提供 --link / Error: --link is required')
  process.exit(2)
}

const UA =
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'

// ---- 极简 cookie jar / minimal cookie jar ----
const jar = new Map()
function storeCookies(res) {
  const set = res.headers.getSetCookie ? res.headers.getSetCookie() : []
  for (const c of set) {
    const [pair] = c.split(';')
    const idx = pair.indexOf('=')
    if (idx > 0) jar.set(pair.slice(0, idx).trim(), pair.slice(idx + 1).trim())
  }
}
function cookieHeader() {
  return [...jar.entries()].map(([k, v]) => `${k}=${v}`).join('; ')
}

function logStep(msg) {
  console.error(`[overleaf-fetch] ${msg}`)
}

// ---- 解析分享链接 / parse the share link ----
// 支持 / supports:
//   https://HOST/read/<token>#<hash>      (只读 / read-only)
//   https://HOST/<token>#<hash>           (读写 / read-write，匿名通常被拒)
const u = new URL(link)
// 安全：仅允许 https + overleaf.com 主机（防 SSRF）/ security: only https + overleaf.com hosts (anti-SSRF)
if (u.protocol !== 'https:' || !/^([a-z0-9-]+\.)*overleaf\.com$/.test(u.hostname)) {
  console.error(
    '错误：仅支持 https 的 overleaf.com 链接 / Error: only https overleaf.com links are supported: ' + link
  )
  process.exit(3)
}
// 锚点仅允许安全字符 / anchor restricted to safe chars
if (u.hash && !/^#[A-Za-z0-9]+$/.test(u.hash)) {
  console.error('错误：链接锚点含非法字符 / Error: invalid characters in link anchor')
  process.exit(3)
}
const origin = u.origin
const hashPrefix = u.hash || '' // 形如 / e.g. "#16fd3a"，作为 tokenHashPrefix 传给 grant
const segments = u.pathname.split('/').filter(Boolean)
let token, isReadOnly
if (segments[0] === 'read' && segments[1]) {
  token = segments[1]
  isReadOnly = true
} else if (segments[0] === 'project' && segments[1]) {
  // 已经是 /project/<id>，无法匿名访问 / already a project URL, not anonymously accessible
  console.error(
    '错误：这是 /project/<id> 链接，需要登录，无法匿名下载。请提供 “只读分享链接”（菜单 → Share → Turn on link sharing → Anyone with this link can view）。\n' +
      'Error: this is a /project/<id> URL which requires login. Please provide a read-only share link (Menu → Share → Anyone with this link can view).'
  )
  process.exit(3)
} else if (segments.length === 1) {
  token = segments[0]
  isReadOnly = false
} else {
  console.error('错误：无法识别的 Overleaf 链接 / Error: unrecognized Overleaf link: ' + link)
  process.exit(3)
}

async function main() {
  // 1) 打开分享页，拿到匿名会话 cookie 与 csrf token
  //    Open the share page to obtain an anonymous session cookie + CSRF token.
  const pagePath = isReadOnly ? `/read/${token}` : `/${token}`
  logStep(`打开分享页 / opening share page: ${origin}${pagePath}`)
  let res = await fetch(origin + pagePath, {
    headers: { 'User-Agent': UA },
    redirect: 'follow',
  })
  storeCookies(res)
  const html = await res.text()
  const csrf = (html.match(/name="ol-csrfToken" content="([^"]+)"/) || [])[1]
  if (!csrf) {
    console.error(
      '错误：未能在分享页找到 CSRF token，链接可能已失效或未开启链接分享。\n' +
        'Error: CSRF token not found on the share page; the link may be invalid or link-sharing is off.'
    )
    process.exit(4)
  }

  // 2) 调用 grant 接口换取 projectId / call grant to obtain the projectId
  const grantPath = isReadOnly ? `/read/${token}/grant` : `/${token}/grant`
  logStep(`请求访问授权 / requesting access grant: ${grantPath}`)
  res = await fetch(origin + grantPath, {
    method: 'POST',
    headers: {
      'User-Agent': UA,
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrf,
      Cookie: cookieHeader(),
      Referer: origin + pagePath,
    },
    body: JSON.stringify({ confirmedByUser: true, tokenHashPrefix: hashPrefix }),
  })
  storeCookies(res)
  const grant = await res.json().catch(() => ({}))
  const redirect = grant.redirect || ''
  const projectId = (redirect.match(/\/project\/([a-f0-9]{24})/) || [])[1]
  if (!projectId) {
    console.error(
      '错误：未能获取 projectId（匿名访问可能被拒，读写链接需要登录）。服务器返回：\n' +
        'Error: could not obtain projectId (anonymous access may be denied; read-write links need login). Server said:\n' +
        JSON.stringify(grant)
    )
    process.exit(5)
  }
  logStep(`projectId = ${projectId}`)

  // 3) 下载项目 zip / download the project zip
  //    不做任何编译器/年份的自动探测；这些一律由用户在 issue 表单里明确选择。
  //    No auto-detection of compiler/year; those come strictly from the user's form choice.
  logStep('下载项目 zip / downloading project zip ...')
  res = await fetch(origin + `/Project/${projectId}/download/zip`, {
    headers: { 'User-Agent': UA, Cookie: cookieHeader() },
    redirect: 'follow',
  })
  if (!res.ok) {
    console.error(`错误：下载 zip 失败 HTTP ${res.status} / Error: zip download failed HTTP ${res.status}`)
    process.exit(6)
  }
  const buf = Buffer.from(await res.arrayBuffer())
  writeFileSync(zipOut, buf)
  logStep(`已保存 / saved ${zipOut} (${buf.length} bytes)`)

  // 4) 写出元数据（仅链接/主机/projectId）/ write metadata (link/host/projectId only)
  const meta = { link, host: origin, projectId }
  writeFileSync(metaOut, JSON.stringify(meta, null, 2))
  logStep(`已保存元数据 / saved metadata ${metaOut}`)
  console.log(JSON.stringify(meta))
}

main().catch(e => {
  console.error('未捕获错误 / uncaught error:', e.stack || e.message)
  process.exit(1)
})
