# cowork/scripts/render-card.ps1
# Render the day's summary (today's pick + 6 category lines) as a hero image.
# HTML/CSS template -> Microsoft Edge headless screenshot (Windows built-in) -> PNG/JPG.
# Text is copied verbatim from the post: nothing is paraphrased or generated.
#
# Usage:
#   pwsh -NoProfile -File cowork/scripts/render-card.ps1 -Post _posts/2026-10-27-briefing.md -Style slide -Out assets/img/picks/2026-10-27.jpg
#   -Style slide : pop dashboard look (navy, colorful category cards, emoji icons)
#   -Style paper : 全国紙朝刊の一面 (portrait 1024x1536, 縦書き・段組・題字; real post text, greeked filler)
#   -Logo        : optional PNG shown in the slide header (default: assets/img/logo.png if present)
# Exit 0 on success, 1 on failure (caller continues without image).

param(
  [Parameter(Mandatory = $true)][string]$Post,
  [ValidateSet("slide", "paper")][string]$Style = "slide",
  [Parameter(Mandatory = $true)][string]$Out,
  [string]$Logo = "assets/img/logo.png",
  [int]$Width = 0,
  [int]$Height = 0,
  [int]$JpegWidth = 0,
  [int]$JpegQuality = 86,
  [int]$Scale = 0
)
$ErrorActionPreference = "Stop"
function Fail($m) { Write-Host "render-card: FAIL - $m"; exit 1 }
if (-not (Test-Path $Post)) { Fail "post not found: $Post" }
. (Join-Path $PSScriptRoot 'paper-text.ps1')
# per-style defaults (slide: 16:9 dashboard; paper: portrait page rendered at 2x for crisp small type)
if ($Style -eq "paper") {
  if (-not $Width) { $Width = 1024 }; if (-not $Height) { $Height = 1536 }; if (-not $JpegWidth) { $JpegWidth = 1024 }; if (-not $Scale) { $Scale = 2 }
} else {
  if (-not $Width) { $Width = 1600 }; if (-not $Height) { $Height = 900 }; if (-not $JpegWidth) { $JpegWidth = 1280 }; if (-not $Scale) { $Scale = 1 }
}
$edge = @("C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe", "C:/Program Files/Microsoft/Edge/Application/msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { Fail "msedge.exe not found" }

# ---- parse ---------------------------------------------------------------
$lines = Get-Content $Post -Encoding UTF8
$dateStr = ([regex]::Match((Split-Path $Post -Leaf), '\d{4}-\d{2}-\d{2}')).Value
$dt = [datetime]::ParseExact($dateStr, "yyyy-MM-dd", $null)
$wdays = "日","月","火","水","木","金","土"
$wday = $wdays[[int]$dt.DayOfWeek]
$postsDir = Split-Path (Resolve-Path $Post) -Parent
$issue = (Get-ChildItem $postsDir -Filter "*-briefing.md" | Where-Object { $_.Name -le (Split-Path $Post -Leaf) }).Count

function NextText($startIdx) {
  for ($i = $startIdx + 1; $i -lt $lines.Count; $i++) {
    $t = $lines[$i].Trim()
    if ($t -eq "") { continue }
    if ($t.StartsWith("**") -or $t.StartsWith("#") -or $t.StartsWith("---") -or $t.StartsWith("<")) { return "" }
    return $t
  }
  return ""
}
$cats = @(
  @{ key = "📰 ビジネス・経済";      emoji = "📰"; label = "ビジネス・経済";    short = "経済";   color = "#ffb547" },
  @{ key = "🤖 AI最新動向";          emoji = "🤖"; label = "AI最新動向";        short = "ＡＩ";   color = "#a78bfa" },
  @{ key = "🚀 新サービス・ローンチ"; emoji = "🚀"; label = "新サービス";        short = "新製品"; color = "#f472b6" },
  @{ key = "🇯🇵 国内技術・ツール";    emoji = "🗾"; label = "国内技術";          short = "国内";   color = "#f87171" },
  @{ key = "📋 開発組織・キャリア";   emoji = "📋"; label = "開発組織・キャリア"; short = "組織";   color = "#4ade80" },
  @{ key = "🔒 セキュリティ";        emoji = "🔒"; label = "セキュリティ";      short = "安全";   color = "#38bdf8" }
)
$pickTitle = ""; $pickReason = ""; $pickCat = ""
for ($i = 0; $i -lt $lines.Count; $i++) {
  $t = $lines[$i].Trim()
  if ($t -eq "**⭐ 今日の1本**") {
    $p = NextText $i
    $mc = [regex]::Match($p, '（→\s*(.+?)\s*を?参照）\s*$')
    if ($mc.Success) { $pickCat = $mc.Groups[1].Value.Trim(); $p = $p.Substring(0, $mc.Index).Trim() }
    $k = $p.IndexOf(" — ")
    if ($k -gt 0) { $pickTitle = $p.Substring(0, $k).Trim(); $pickReason = $p.Substring($k + 3).Trim() } else { $pickTitle = $p }
  }
  foreach ($c in $cats) { if ($t -eq ("**" + $c.key + "**")) { $c.text = (NextText $i) } }
}
if (-not $pickTitle) { $pickTitle = "$dateStr デイリーブリーフィング" }
foreach ($c in $cats) { if (-not $c.text) { $c.text = "本日の更新なし" }; $c.count = 0; $c.articles = @() }
# per-category article list from the <details> blocks (title / summary / 📖 digest) - used as body text
$cur = $null; $inDigest = $false; $art = $null
for ($i = 0; $i -lt $lines.Count; $i++) {
  $t = $lines[$i].Trim()
  if ($t -match '^<summary>(.+?)（(\d+)件）</summary>$') {
    $cur = $null; $art = $null
    foreach ($c in $cats) { if ($Matches[1] -eq $c.key) { $cur = $c; $c.count = [int]$Matches[2] } }
    continue
  }
  if (-not $cur) { continue }
  if ($t -like '<details><summary>📖*') { $inDigest = $true; continue }
  if ($t -eq '</details>') { if ($inDigest) { $inDigest = $false } else { $cur = $null; $art = $null }; continue }
  if ($t -match '^- \*\*(.+?)\*\*') { $art = @{ title = $Matches[1]; summary = ""; digest = "" }; $cur.articles += $art; continue }
  if (-not $art -or $t -eq "" -or $t.StartsWith("→") -or $t.StartsWith("<")) { continue }
  if ($inDigest) { $art.digest += $t } else { $art.summary += $t }
}
function Esc($s) { [System.Net.WebUtility]::HtmlEncode([string]$s) }

$logoTag = ""
if ($Logo -and (Test-Path $Logo)) { $logoTag = '<img class="logo" src="file:///' + ((Resolve-Path $Logo).Path -replace '\\', '/') + '">' }

# ---- templates -----------------------------------------------------------
if ($Style -eq "slide") {
  $cards = ""
  foreach ($c in $cats) {
    $cards += '<div class="card" style="--c:' + $c.color + '"><div class="ic">' + $c.emoji + '</div><div class="lb">' + (Esc $c.label) + '</div><div class="tx">' + (Esc $c.text) + '</div></div>'
  }
  $html = @'
<!doctype html><html lang="ja"><meta charset="utf-8"><style>
*{box-sizing:border-box;margin:0}
body{width:1600px;height:900px;overflow:hidden;color:#eef3fb;font-family:"Yu Gothic UI","Segoe UI","Segoe UI Emoji",sans-serif;
 background:#0b1020;background-image:
 radial-gradient(900px 520px at -5% -10%,rgba(79,216,196,.38),transparent 60%),
 radial-gradient(800px 600px at 105% 0%,rgba(167,139,250,.35),transparent 60%),
 radial-gradient(700px 500px at 60% 115%,rgba(244,114,182,.28),transparent 60%),
 radial-gradient(circle at 1px 1px,rgba(255,255,255,.06) 1px,transparent 1.6px);background-size:auto,auto,auto,28px 28px}
.wrap{padding:44px 64px 40px}
.top{display:flex;align-items:center;gap:16px;margin-bottom:26px}
.logo{width:52px;height:52px;border-radius:14px;box-shadow:0 6px 18px rgba(0,0,0,.35)}
.brand{font-family:Consolas,"Cascadia Mono",monospace;font-size:22px;letter-spacing:.18em;color:#7ee8d8}
.date{margin-left:auto;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.14);border-radius:999px;padding:8px 18px;font-size:22px;font-weight:600}
.hero{display:flex;gap:28px;align-items:flex-start;margin-bottom:28px}
.star{flex:none;width:92px;height:92px;border-radius:26px;display:grid;place-items:center;font-size:52px;
 background:linear-gradient(135deg,#ffd166,#ff8fab);box-shadow:0 10px 30px rgba(255,160,120,.35)}
.kick{display:inline-flex;gap:10px;align-items:center;font-size:20px;font-weight:700;color:#ffd166;letter-spacing:.06em;margin-bottom:8px}
.kick .cat{background:rgba(255,255,255,.1);color:#eef3fb;border-radius:999px;padding:3px 14px;font-weight:600}
.h1{font-size:54px;font-weight:800;line-height:1.22;letter-spacing:-.01em;margin-bottom:10px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.why{font-size:24px;line-height:1.5;color:#b7c3d6;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:20px}
.card{position:relative;background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.12);border-radius:22px;padding:18px 20px 16px 20px;height:246px;overflow:hidden}
.card:before{content:"";position:absolute;left:0;top:0;right:0;height:6px;background:var(--c)}
.ic{font-size:34px;line-height:1;margin-bottom:8px}
.lb{font-size:19px;font-weight:800;color:var(--c);margin-bottom:6px;letter-spacing:.02em}
.tx{font-size:19px;line-height:1.5;color:#e3eaf5;display:-webkit-box;-webkit-line-clamp:5;-webkit-box-orient:vertical;overflow:hidden}
</style><body><div class="wrap">
<div class="top">{{LOGO}}<div class="brand">DAILY BRIEFING</div><div class="date">{{DATE}}（{{WDAY}}）</div></div>
<div class="hero"><div class="star">⭐</div><div><div class="kick">今日の1本 {{PICKCAT}}</div><div class="h1">{{PICKTITLE}}</div><div class="why">{{PICKREASON}}</div></div></div>
<div class="grid">{{CARDS}}</div>
</div></body></html>
'@
  $pickCatTag = if ($pickCat) { '<span class="cat">' + (Esc $pickCat) + '</span>' } else { "" }
  $html = $html.Replace("{{LOGO}}", $logoTag).Replace("{{DATE}}", $dateStr).Replace("{{WDAY}}", $wday).Replace("{{PICKCAT}}", $pickCatTag).Replace("{{PICKTITLE}}", (Esc $pickTitle)).Replace("{{PICKREASON}}", (Esc $pickReason)).Replace("{{CARDS}}", $cards)
} else {
  # ---- paper: 全国紙朝刊の一面 (縦書き右起こし・段組・題字) --------------------
  # Readable text = post text only (⭐, category summaries, article titles/summaries/📖).
  # Column tails and ads are greeked filler (random characters, low contrast) for texture.
  $rnd = [System.Random]::new([int]$dt.ToString("yyyyMMdd"))
  $pool = "国会議員政府経済市場企業技術開発発表報告社会地域対応確認調査結果影響可能性必要今後方針説明指摘関係者協議計画実施予定来年度前年比増加減少投資事業製品利用者環境安全対策課題世界各国日本東京大阪情報通信産業研究機関大学連携強化推進改革制度見直検討導入拡大縮小改善向上維持管理運営支援提供開始終了期間時間午前午後朝夕昨日今日明日週間月間年間のにはをがとでもたしてないるかられうこすまんきつくさりあおよえみねほわけせそちぬふむめゆろ"
  function Greek($n) {
    $sb = New-Object Text.StringBuilder
    $run = 0; $len = $rnd.Next(14, 30)
    while ($sb.Length -lt $n) {
      [void]$sb.Append($pool[$rnd.Next($pool.Length)]); $run++
      if ($run -ge $len) { [void]$sb.Append("。"); $run = 0; $len = $rnd.Next(14, 30) }
      elseif ($run % 9 -eq 0 -and $rnd.Next(3) -eq 0) { [void]$sb.Append("、") }
    }
    return $sb.ToString()
  }
  function Clean($s) { (([string]$s) -replace '\*\*', '') -replace '\[([^\]]+)\]\([^)]+\)', '$1' }
  function Tcy($escaped) { [regex]::Replace($escaped, '(?<![0-9A-Za-z.])([0-9]{1,2})(?![0-9A-Za-z.])', '<span class="tcy">$1</span>') }
  function Txt($s) { Tcy (Esc (Clean $s)) }
  function BodyHtml($c, $first, $greekLen) {
    $h = '<p class="ld">' + (Txt $c.text) + '</p>'
    $arts = @($c.articles)
    if ($first) {
      # put the article that matches today's pick first (longest common prefix >= 4 chars)
      $best = $null; $bestLen = 3
      foreach ($a in $arts) { $n = 0; while ($n -lt $a.title.Length -and $n -lt $first.Length -and $a.title[$n] -eq $first[$n]) { $n++ }; if ($n -gt $bestLen) { $bestLen = $n; $best = $a } }
      if ($best) { $arts = @($best) + @($arts | Where-Object { $_ -ne $best }) }
    }
    foreach ($a in $arts) { $h += '<h4>' + (Txt $a.title) + '</h4><p>' + (Txt ($a.summary + $a.digest)) + '</p>' }
    $h += '<p class="greek">' + (Greek $greekLen) + '</p>'
    return $h
  }
  $pick = $cats | Where-Object { $pickCat -and $pickCat.Contains($_.label) } | Select-Object -First 1
  $leadBody = if ($pick) { BodyHtml $pick $pickTitle 900 } else { '<p class="ld">' + (Txt $pickReason) + '</p><p class="greek">' + (Greek 900) + '</p>' }
  $h1 = if ($pickTitle.Length -le 20) { 60 } elseif ($pickTitle.Length -le 32) { 52 } elseif ($pickTitle.Length -le 44) { 46 } else { 40 }
  # きょうの紙面: two categories per vertical line (e.g. 経済4本　ＡＩ3本)
  $items = @(); foreach ($c in $cats) { $items += (Esc $c.short) + $(if ($c.count -gt 0) { (Tcy ([string]$c.count)) + '本' } else { 'なし' }) }
  $index = ""; for ($k = 0; $k -lt $items.Count; $k += 2) { $index += '<span>' + (($items[$k..($k + 1)]) -join '　') + '</span>' }
  # lower stories: up to 4 categories (page width allows ~5 lines per 段 each), skipping the pick's and empty ones
  $stories = ""; $n = 0
  foreach ($c in $cats) {
    if ($c.text -eq "本日の更新なし" -or ($pick -and $c.key -eq $pick.key)) { continue }
    $stories += '<section class="st"><div class="sh v"><span class="tag">' + (Esc $c.label) + '</span><h2 class="h2">' + (Txt (FirstSentence $c.text 30)) + '</h2></div><div class="sb v">' + (BodyHtml $c $null 500) + '</div></section>'
    $n++; if ($n -ge 4) { break }
  }
  $h2 = 28
  $ads = ""; foreach ($k in 1..3) { $ads += '<div class="ad"><div class="t"></div><div class="b"></div></div>' }
  $colm = '<b>編集室から</b><p>この紙面は当日の本文から自動で組版したものです。記事の正本はこの下の本文と「詳しく読む」をご覧ください。</p><p class="greek">' + (Greek 400) + '</p>'
  $jpDate = $dt.ToString("yyyy年M月d日") + "<br>（" + $wday + "曜日）"
  $html = @'
<!doctype html><html lang="ja"><meta charset="utf-8"><style>
*{box-sizing:border-box;margin:0;padding:0}
html,body{width:1024px;height:1536px;overflow:hidden}
body{position:relative;color:#1b1713;font-family:"Yu Mincho","Noto Serif JP",serif;background:#ece7dc;
 background-image:radial-gradient(1100px 900px at 30% 10%,rgba(255,255,255,.45),transparent 70%),repeating-linear-gradient(0deg,rgba(0,0,0,.022) 0 1px,transparent 1px 3px),repeating-linear-gradient(90deg,rgba(0,0,0,.015) 0 1px,transparent 1px 5px)}
.v{writing-mode:vertical-rl;text-orientation:mixed}
.tcy{text-combine-upright:all}
.hd{font-family:"Noto Serif JP","Yu Mincho",serif;font-weight:900}
.go{font-family:"BIZ UDGothic","Yu Gothic",sans-serif}
.page{position:absolute;left:30px;top:26px;width:964px;height:1484px;display:flex;flex-direction:column}
.top{height:700px;display:flex;flex-direction:row-reverse;gap:16px}
.mast{flex:none;width:120px;display:flex;flex-direction:column;align-items:center}
.mast .box{width:120px;height:560px;border:4px double #1b1713;padding:18px 0;display:flex;justify-content:center;
 background:repeating-linear-gradient(45deg,rgba(176,52,36,.26) 0 1px,transparent 1px 4px),repeating-linear-gradient(-45deg,rgba(176,52,36,.18) 0 1px,transparent 1px 4px)}
.mast .box span{font-size:42px;line-height:1;letter-spacing:.02em}
.mast .dt{margin-top:10px;height:130px;font-size:12.5px;letter-spacing:.06em;line-height:1.4}
.lead{flex:1;min-width:0;display:flex;flex-direction:row-reverse;gap:14px}
.hl{flex:none;height:100%}
.kick{display:block;inline-size:max-content;background:#1b1713;color:#ece7dc;font-weight:700;font-size:17px;letter-spacing:.25em;padding:14px 6px;margin-left:14px}
.h1{font-size:{{H1SIZE}}px;line-height:1.2;letter-spacing:.03em;margin-left:14px}
.sub{font-family:"Noto Serif JP","Yu Mincho",serif;font-weight:700;font-size:23px;line-height:1.45;letter-spacing:.02em;color:#2a2520;margin-left:12px}
.body,.sb{column-gap:18px;column-rule:1px solid #bdb5a8;column-fill:auto;overflow:hidden;letter-spacing:.03em}
.body{flex:1;min-width:0;height:100%;column-count:3;font-size:13.5px;line-height:1.6}
.body h4,.sb h4{font-family:"Noto Serif JP","Yu Mincho",serif;font-weight:700;font-size:17px;line-height:1.3;margin-left:10px;margin-right:4px}
.body p,.sb p{margin-left:6px;text-indent:1em}
.ld{font-weight:700}
.greek{color:#7a7268;opacity:.36;filter:blur(.45px)}
.left{flex:none;width:124px;display:flex;flex-direction:column;gap:12px}
.idx{height:210px;border:1.5px solid #1b1713;padding:10px 8px;font-size:14px;line-height:1.5;letter-spacing:.06em;overflow:hidden}
.idx b{display:block;inline-size:max-content;background:#1b1713;color:#ece7dc;padding:8px 3px;margin-left:8px;letter-spacing:.2em}
.idx > span{display:block}
.colm{flex:1;min-height:0;border-top:1px solid #1b1713;padding-top:8px;font-size:13px;line-height:1.6;overflow:hidden}
.colm b{display:block;inline-size:max-content;border:1.5px solid #1b1713;padding:6px 3px;margin-left:8px;letter-spacing:.2em;font-weight:700}
.colm p{margin-left:5px;text-indent:1em}
.rule{border-top:2px solid #1b1713;margin-top:12px}
.low{height:540px;display:flex;flex-direction:row-reverse;padding-top:12px}
.st{flex:1;min-width:0;display:flex;flex-direction:row-reverse;gap:10px;padding:0 12px;border-right:1px solid #1b1713}
.st:first-child{border-right:0}
.sh{flex:none;height:100%}
.tag{display:block;inline-size:max-content;border:1.5px solid #1b1713;font-size:13px;letter-spacing:.2em;padding:8px 3px;margin-left:10px}
.h2{font-size:{{H2SIZE}}px;line-height:1.2;letter-spacing:.03em;margin-left:10px}
.sb{flex:1;min-width:0;height:100%;column-count:2;font-size:13px;line-height:1.6}
.ads{height:150px;margin-top:12px;border-top:3px double #1b1713;padding-top:10px;display:flex;flex-direction:row-reverse;gap:14px}
.ad{flex:1;border:1px solid #8f877b;padding:10px;display:flex;flex-direction:row-reverse;gap:10px;overflow:hidden}
.ad .t{width:22px;background:repeating-linear-gradient(180deg,#9a9286 0 14px,transparent 14px 18px);opacity:.55}
.ad .b{flex:1;min-width:0;background:repeating-linear-gradient(90deg,#b5ada0 0 1.5px,transparent 1.5px 7px),repeating-linear-gradient(180deg,transparent 0 46%,#ece7dc 46% 54%);opacity:.6}
.folio{margin-top:8px;border-top:1px solid #1b1713;padding-top:5px;display:flex;justify-content:space-between;font-size:12px;letter-spacing:.14em;color:#4a443c}
</style><body><div class="page">
<div class="top">
 <div class="mast"><div class="box"><span class="v hd">デイリーブリーフィング</span></div><div class="dt v go">{{JPDATE}}<br>第{{ISSUE}}号</div></div>
 <div class="lead">
  <div class="hl v"><span class="kick go">今日の1本</span><h1 class="h1 hd">{{PICKTITLE}}</h1><p class="sub">{{PICKREASON}}</p></div>
  <div class="body v">{{LEADBODY}}</div>
 </div>
 <div class="left"><div class="idx v go"><b>きょうの紙面</b>{{INDEX}}</div><div class="colm v">{{COLM}}</div></div>
</div>
<div class="rule"></div>
<div class="low">{{STORIES}}</div>
<div class="ads">{{ADS}}</div>
<div class="folio go"><span>デイリーブリーフィング　{{DATE}}　毎朝7時 自動発行</span><span>一面</span></div>
</div></body></html>
'@
  $html = $html.Replace("{{H1SIZE}}", [string]$h1).Replace("{{H2SIZE}}", [string]$h2).Replace("{{ISSUE}}", (Tcy ([string]$issue))).Replace("{{JPDATE}}", (Tcy $jpDate)).Replace("{{PICKTITLE}}", (Txt $pickTitle)).Replace("{{PICKREASON}}", (Txt $pickReason)).Replace("{{LEADBODY}}", $leadBody).Replace("{{INDEX}}", $index).Replace("{{COLM}}", $colm).Replace("{{STORIES}}", $stories).Replace("{{ADS}}", $ads).Replace("{{DATE}}", $dateStr)
}

# ---- render --------------------------------------------------------------
$work = Join-Path ([IO.Path]::GetTempPath()) ("card-" + $dateStr + "-" + $Style)
New-Item -ItemType Directory -Force $work | Out-Null
$htmlPath = Join-Path $work "card.html"
[IO.File]::WriteAllText($htmlPath, $html, (New-Object Text.UTF8Encoding $false))
$pngPath = Join-Path $work "card.png"
Remove-Item $pngPath -ErrorAction SilentlyContinue
$fileUrl = "file:///" + ($htmlPath -replace '\\', '/')
# -Wait also waits for Edge child processes (the renderer writes the PNG); WaitForExit() alone returns too early.
$edgeArgs = @("--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run", "--no-default-browser-check", "--user-data-dir=$work/profile", "--force-device-scale-factor=$Scale", "--window-size=$Width,$Height", "--screenshot=$pngPath", $fileUrl)
$job = Start-Job -ScriptBlock { param($e, $a) Start-Process -FilePath $e -ArgumentList $a -NoNewWindow -Wait } -ArgumentList $edge, $edgeArgs
if (-not (Wait-Job $job -Timeout 90)) { Stop-Job $job; Remove-Job $job -Force; Fail "edge timed out" }
Remove-Job $job -Force
# at 2x scale the renderer may still be writing the PNG after the main process exits: wait for a stable file
$deadline = (Get-Date).AddSeconds(30); $prev = -1
while ((Get-Date) -lt $deadline) {
  if (Test-Path $pngPath) { $len = (Get-Item $pngPath).Length; if ($len -gt 0 -and $len -eq $prev) { break }; $prev = $len }
  Start-Sleep -Milliseconds 500
}
if (-not (Test-Path $pngPath)) { Fail "edge produced no screenshot" }

$dir = Split-Path $Out -Parent
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
if ($Out.ToLower().EndsWith(".jpg")) {
  Add-Type -AssemblyName System.Drawing
  $img = [System.Drawing.Image]::FromFile($pngPath)
  $h = [int]($img.Height * $JpegWidth / $img.Width)
  $bmp = New-Object System.Drawing.Bitmap $JpegWidth, $h
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($img, 0, 0, $JpegWidth, $h)
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]$JpegQuality)
  $bmp.Save($Out, $codec, $ep)
  $g.Dispose(); $bmp.Dispose(); $img.Dispose()
} else {
  Copy-Item $pngPath $Out -Force
}
Write-Host ("render-card: OK -> $Out (" + [int]((Get-Item $Out).Length / 1KB) + "KB, style=$Style)")
exit 0
