# cowork/scripts/render-card.ps1
# Render the day's summary (today's pick + 6 category lines) as a hero image.
# HTML/CSS template -> Microsoft Edge headless screenshot (Windows built-in) -> PNG/JPG.
# Text is copied verbatim from the post: nothing is paraphrased or generated.
#
# Usage:
#   pwsh -NoProfile -File cowork/scripts/render-card.ps1 -Post _posts/2026-10-27-briefing.md -Style slide -Out assets/img/picks/2026-10-27.jpg
#   -Style slide : pop dashboard look (navy, colorful category cards, emoji icons)
#   -Style paper : Japanese newspaper front page (masthead, ears, vertical lead, 3 columns)
#   -Logo        : optional PNG shown in the slide header (default: assets/img/logo.png if present)
# Exit 0 on success, 1 on failure (caller continues without image).

param(
  [Parameter(Mandatory = $true)][string]$Post,
  [ValidateSet("slide", "paper")][string]$Style = "slide",
  [Parameter(Mandatory = $true)][string]$Out,
  [string]$Logo = "assets/img/logo.png",
  [int]$Width = 1600,
  [int]$Height = 900,
  [int]$JpegWidth = 1280,
  [int]$JpegQuality = 86
)
$ErrorActionPreference = "Stop"
function Fail($m) { Write-Host "render-card: FAIL - $m"; exit 1 }
if (-not (Test-Path $Post)) { Fail "post not found: $Post" }
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
foreach ($c in $cats) { if (-not $c.text) { $c.text = "本日の更新なし" } }
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
  $cols = ""
  foreach ($c in $cats) {
    $cols += '<section class="st"><h3><span class="tag">' + (Esc $c.short) + '</span>' + (Esc $c.label) + '</h3><p>' + (Esc $c.text) + '</p></section>'
  }
  $jpDate = $dt.ToString("yyyy年M月d日") + "（" + $wday + "曜日）"
  $html = @'
<!doctype html><html lang="ja"><meta charset="utf-8"><style>
*{box-sizing:border-box;margin:0}
body{position:relative;width:1600px;height:900px;overflow:hidden;color:#17130f;font-family:"Yu Mincho","游明朝",serif;
 background:#f3ecdd;background-image:repeating-linear-gradient(0deg,rgba(0,0,0,.025) 0 1px,transparent 1px 3px),radial-gradient(1200px 700px at 50% 20%,rgba(255,255,255,.55),transparent 70%)}
.wrap{padding:26px 54px 22px}
.mast{display:grid;grid-template-columns:230px 1fr 230px;align-items:center;gap:18px;padding-bottom:10px;border-bottom:4px double #17130f}
.ear{border:2px solid #17130f;padding:8px 10px;font-size:15px;line-height:1.55;font-family:"Yu Gothic UI",sans-serif}
.ear b{display:block;font-size:17px}
.title{text-align:center;font-family:"Yu Mincho Demibold","Yu Mincho",serif;font-weight:900;font-size:66px;letter-spacing:.14em;line-height:1.1}
.sub{text-align:center;font-family:"Yu Gothic UI",sans-serif;font-size:14px;letter-spacing:.3em;color:#4a4036;margin-top:6px}
.lead{display:grid;grid-template-columns:64px 1fr;gap:26px;align-items:stretch;padding:18px 0 16px;border-bottom:1px solid #17130f}
.kick{display:inline-block;background:#17130f;color:#f3ecdd;font-family:"Yu Gothic UI",sans-serif;font-weight:700;font-size:16px;letter-spacing:.2em;padding:4px 12px;margin-bottom:10px}
.h1{font-family:"Yu Mincho Demibold","Yu Mincho",serif;font-weight:900;font-size:50px;line-height:1.28;letter-spacing:.02em;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.vkick{writing-mode:vertical-rl;text-orientation:upright;background:#17130f;color:#f3ecdd;font-family:"Yu Mincho Demibold","Yu Mincho",serif;font-weight:900;font-size:26px;letter-spacing:.25em;padding:16px 10px;display:flex;align-items:center;justify-content:center}
.leadp{font-size:21px;line-height:1.7;margin-top:12px;color:#2a241e;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.body{column-count:3;column-gap:34px;column-rule:1px solid #17130f;padding-top:16px;height:505px}
.st{break-inside:avoid;margin-bottom:22px}
.st h3{font-family:"Yu Gothic UI",sans-serif;font-size:19px;font-weight:700;margin-bottom:6px;display:flex;align-items:center;gap:8px}
.tag{display:inline-block;border:1.5px solid #17130f;padding:1px 6px;font-size:15px;letter-spacing:.1em}
.st p{font-size:20.5px;line-height:1.75;text-align:justify;text-justify:inter-character;line-break:strict;display:-webkit-box;-webkit-line-clamp:6;-webkit-box-orient:vertical;overflow:hidden}
.folio{position:absolute;left:54px;right:54px;bottom:16px;border-top:1px solid #17130f;padding-top:6px;display:flex;justify-content:space-between;font-family:"Yu Gothic UI",sans-serif;font-size:13px;letter-spacing:.14em;color:#4a4036}
</style><body><div class="wrap">
<div class="mast">
 <div class="ear"><b>第{{ISSUE}}号</b>{{JPDATE}}<br>毎朝7時 自動発行</div>
 <div><div class="title">デイリーブリーフィング</div><div class="sub">AI・ビジネス・技術 ― 主要ソースから毎朝要約</div></div>
 <div class="ear"><b>本日の紙面</b>今日の1本／経済／AI／新製品／国内／組織／安全</div>
</div>
<div class="lead"><div class="vkick">今日の一本</div><div><div class="h1">{{PICKTITLE}}</div><p class="leadp">{{PICKREASON}}</p></div></div>
<div class="body">{{COLS}}</div>
</div><div class="folio"><span>デイリーブリーフィング　{{DATE}}</span><span>一面</span></div></body></html>
'@
  $html = $html.Replace("{{ISSUE}}", [string]$issue).Replace("{{JPDATE}}", $jpDate).Replace("{{PICKTITLE}}", (Esc $pickTitle)).Replace("{{PICKREASON}}", (Esc $pickReason)).Replace("{{COLS}}", $cols).Replace("{{DATE}}", $dateStr)
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
$edgeArgs = @("--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run", "--no-default-browser-check", "--user-data-dir=$work/profile", "--force-device-scale-factor=1", "--window-size=$Width,$Height", "--screenshot=$pngPath", $fileUrl)
$job = Start-Job -ScriptBlock { param($e, $a) Start-Process -FilePath $e -ArgumentList $a -NoNewWindow -Wait } -ArgumentList $edge, $edgeArgs
if (-not (Wait-Job $job -Timeout 90)) { Stop-Job $job; Remove-Job $job -Force; Fail "edge timed out" }
Remove-Job $job -Force
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
