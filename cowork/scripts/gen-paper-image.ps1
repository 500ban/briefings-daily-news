# cowork/scripts/gen-paper-image.ps1
# Generate a Japanese "newspaper front page" illustration for the day's briefing
# with Codex CLI (built-in imagegen), then save it as assets/img/picks/<date>.jpg.
# The page text stays the source of truth; this image is an illustration and may
# contain minor text imperfections. On failure the caller falls back to
# cowork/scripts/render-card.ps1 -Style paper (deterministic HTML rendering).
#
# Usage:
#   pwsh -NoProfile -File cowork/scripts/gen-paper-image.ps1 -Post _posts/2026-10-27-briefing.md
#   (optional) -Out assets/img/picks/2026-10-27.jpg -TimeoutSec 300
# Exit codes: 0 = image written, 1 = failed (no file written).
# Requirements: Codex CLI via npm (-g @openai/codex) logged in with ChatGPT; node on PATH.

param(
  [Parameter(Mandatory = $true)][string]$Post,
  [string]$Out = "",
  [int]$TimeoutSec = 300,
  [int]$Width = 1024,
  [int]$Quality = 82,
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
function Fail($m) { Write-Host "gen-paper-image: FAIL - $m"; exit 1 }
if (-not (Test-Path $Post)) { Fail "post not found: $Post" }

$codexJs = Join-Path $env:APPDATA 'npm\node_modules\@openai\codex\bin\codex.js'
if (-not (Test-Path $codexJs)) { Fail "codex.js not found at $codexJs" }
$nodeExe = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $nodeExe) { Fail "node not found on PATH" }

# ---- parse the post (same rules as render-card.ps1) ----------------------
$lines = Get-Content $Post -Encoding UTF8
$dateStr = ([regex]::Match((Split-Path $Post -Leaf), '\d{4}-\d{2}-\d{2}')).Value
$dt = [datetime]::ParseExact($dateStr, "yyyy-MM-dd", $null)
$wdays = "日","月","火","水","木","金","土"
$jpDate = $dt.ToString("yyyy年M月d日") + "（" + $wdays[[int]$dt.DayOfWeek] + "曜日）"
if (-not $Out) { $Out = "assets/img/picks/$dateStr.jpg" }

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
  @{ key = "📰 ビジネス・経済";      label = "ビジネス・経済" },
  @{ key = "🤖 AI最新動向";          label = "AI最新動向" },
  @{ key = "🚀 新サービス・ローンチ"; label = "新サービス" },
  @{ key = "🇯🇵 国内技術・ツール";    label = "国内技術" },
  @{ key = "📋 開発組織・キャリア";   label = "開発組織・キャリア" },
  @{ key = "🔒 セキュリティ";        label = "セキュリティ" }
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
if (-not $pickTitle) { Fail "today's pick not found in post" }

# First sentence of each category, trimmed, skipping the pick's own category and empty days.
function TrimEnding($frag) {
  # drop conjunctive / particle endings so the fragment reads as 体言止め (2 passes:
  # e.g. 「準備していると報」→「準備している」→「準備」)
  $endings = '(と報告|と報|と発表|と述べ|と説明|と指摘|している|しており|ており|ている|いる|になった|となった|なった|であり|であるが|しながら|ながら|したが|だが|ので|ため|つつ|から|より|され|して|受けて|受け|向けて|向け|通じて|通じ|踏まえて|踏まえ|含めて|含め|加えて|加え|巡り|めぐり|対して|対し|伴い|応じて|応じ|超えて|超え|続けて|続け|進めて|進め|広げて|広げ|始めて|始め|求めて|求め|認めて|認め|高めて|高め|強めて|強め|迎えて|迎え|控えて|控え|備えて|備え|変えて|変え|与えて|与え|抑えて|抑え|整えて|整え|据えて|据え|する|なる|ある|し|て|が|で|に|を|と|へ|は|も|の)$'
  $t = $frag
  for ($n = 0; $n -lt 2; $n++) { $t = [regex]::Replace($t, $endings, '') }
  return $t.TrimEnd('、', ' ', '・', '：', '/', '／')
}
function CleanCut($frag, $full) {
  # never end inside 「」, inside an ASCII phrase (incl. "AWS Lambda"), a katakana run, or a kanji compound
  $open = $frag.LastIndexOf("「"); $close = $frag.LastIndexOf("」")
  if ($open -gt $close) { $frag = $frag.Substring(0, $open) }
  if ($frag.Length -gt 0 -and $frag.Length -lt $full.Length) {
    $last = $frag[$frag.Length - 1]; $next = $full[$frag.Length]
    $ascii = '[-A-Za-z0-9.]'; $asciiRun = '[-A-Za-z0-9. ]'; $kata = '[゠-ヿ]'; $kanji = '[一-鿿]'
    $nextIsAscii = ($next -match $ascii) -or ($next -eq ' ' -and $full.Length -gt $frag.Length + 1 -and $full[$frag.Length + 1] -match $ascii)
    $pat = $null
    if ($last -match $ascii -and $nextIsAscii) { $pat = $asciiRun }
    elseif ($last -match $kata -and $next -match $kata) { $pat = $kata }
    elseif ($last -match $kanji -and $next -match $kanji) { $pat = $kanji }
    if ($pat) {
      $i = $frag.Length - 1
      while ($i -ge 0 -and $frag[$i] -match $pat) { $i-- }
      if ($i -ge 6) { $frag = $frag.Substring(0, $i + 1) }
    }
  }
  return $frag
}
function FirstSentence($s, $max) {
  # Headline for a lower box: first sentence, shortened to ~$max chars, ending as 体言止め.
  # Candidates: (a) cut at the last clause boundary (、) (b) hard cut at $max, both cleaned
  # (no cut inside 「」 / ASCII word / katakana run) and trimmed; prefer (a) if >= 18 chars remain.
  $s = [string]$s
  $k = $s.IndexOf("。"); if ($k -gt 0) { $s = $s.Substring(0, $k) }
  if ($s.Length -le $max) { return $s }
  $hard = $s.Substring(0, $max)
  $cands = @()
  $cut = $hard.LastIndexOf("、")
  if ($cut -ge 12) { $cands += (TrimEnding (CleanCut $s.Substring(0, $cut) $s)) }
  $cands += (TrimEnding (CleanCut $hard $s))
  foreach ($c in $cands) { if ($c.Length -ge 18) { return $c } }
  foreach ($c in $cands) { if ($c.Length -ge 8) { return $c } }
  return $hard
}
$boxes = @()
foreach ($c in $cats) {
  if (-not $c.text -or $c.text -eq "本日の更新なし") { continue }
  if ($pickCat -and $pickCat.Contains($c.label)) { continue }
  $boxes += ($c.label + "：" + (FirstSentence $c.text 36))
  if ($boxes.Count -ge 4) { break }
}
$boxText = ($boxes | ForEach-Object { "<<" + $_ + ">>" }) -join " "

# ---- prompt ----------------------------------------------------------------
$prompt = "Create ONE image with the built-in image generation (imagegen) capability: a realistic scan of the front page (一面) of a Japanese national morning broadsheet newspaper (全国紙の朝刊), portrait 1024x1536, filling the whole frame edge to edge. " +
  "It must look like a real printed newspaper page, NOT an infographic, poster, or web card: traditional Japanese newspaper layout with vertical writing (縦書き) read right-to-left, a dense grid of many narrow text columns (段組) separated by thin hairline rules, headlines in bold Mincho (明朝体) newspaper type of varying sizes, and a lot of small body text. " +
  "Body text must be rendered as tiny unreadable greeked newsprint texture (fine grey lines of pseudo-characters), never as readable sentences. " +
  "Masthead (題字) exactly: デイリーブリーフィング, written vertically inside a bordered box at the top-right corner, with the date exactly: $jpDate in small type beneath it. " +
  "Top story at the upper right, next to the masthead, with a small kicker label 今日の1本 above a large multi-line vertical headline that reads exactly: $pickTitle and a smaller vertical sub-headline (袖見出し) exactly: $pickReason " +
  "Place ONE small monochrome halftone-style illustration or simple line chart related to the top story inside its columns, with a thin caption rule; no large icons, no cartoon illustrations, no clip art. " +
  "The lower and left parts of the page carry smaller articles, each with its own vertical headline using these exact Japanese texts (the << >> markers only delimit the texts; never draw them or any quotation marks): $boxText " +
  "Colors: off-white/grey newsprint paper with faint fibre texture and slight ink spread; black ink only, except the masthead box may use a single muted vermilion (朱) accent. No other colors. " +
  "Render every Japanese headline exactly as given and legibly; Latin letters and numerals inside vertical text may be rotated or set 縦中横. Use ONLY the provided texts for anything readable; do not invent other headlines, facts, names, or numbers; advertisements or other blocks must be greeked, not readable. " +
  "No brand logos, no real people, no photographs, no watermark, no border frame around the image. " +
  "Do not try to copy or move the file; the default save location is fine. Reply with only the absolute path of the saved PNG."
$prompt = ($prompt -replace '"', "'") -replace '[\r\n]+', ' '

if ($DryRun) {
  Write-Host "pick : $pickTitle"
  foreach ($b in $boxes) { Write-Host "box  : $b" }
  exit 0
}

# ---- run codex (node + JS entry; npm shim cannot be launched by Start-Process) --
$genRoot = Join-Path $env:USERPROFILE '.codex\generated_images'
$work = Join-Path ([IO.Path]::GetTempPath()) ("paper-" + $dateStr)
New-Item -ItemType Directory -Force $work | Out-Null
$lastMsg = Join-Path $work "last-message.txt"
Remove-Item $lastMsg -ErrorAction SilentlyContinue
$argLine = (@($codexJs, "exec", "-C", $work, "--skip-git-repo-check", "-s", "read-only", "-o", $lastMsg, $prompt) | ForEach-Object { '"' + $_ + '"' }) -join " "
$started = Get-Date
$proc = Start-Process -FilePath $nodeExe -ArgumentList $argLine -NoNewWindow -PassThru `
  -RedirectStandardOutput (Join-Path $work "stdout.txt") -RedirectStandardError (Join-Path $work "stderr.txt")
if (-not $proc.WaitForExit($TimeoutSec * 1000)) { try { $proc.Kill() } catch {}; Fail "codex exec timed out after ${TimeoutSec}s" }

$src = $null
if (Test-Path $lastMsg) {
  $m = [regex]::Match((Get-Content $lastMsg -Raw), '[A-Za-z]:[^\r\n"]+?\.png')
  if ($m.Success -and (Test-Path $m.Value)) { $src = $m.Value }
}
if (-not $src -and (Test-Path $genRoot)) {
  $cand = Get-ChildItem $genRoot -Recurse -Filter *.png -File |
    Where-Object { $_.CreationTime -ge $started.AddSeconds(-5) } |
    Sort-Object CreationTime -Descending | Select-Object -First 1
  if ($cand) { $src = $cand.FullName }
}
if (-not $src) { Fail "no generated PNG found (codex exit $($proc.ExitCode))" }

# ---- convert to JPEG ---------------------------------------------------------
try {
  Add-Type -AssemblyName System.Drawing
  $img = [System.Drawing.Image]::FromFile($src)
  $w = [Math]::Min($Width, $img.Width)
  $h = [int]($img.Height * $w / $img.Width)
  $bmp = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($img, 0, 0, $w, $h)
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]$Quality)
  $dir = Split-Path $Out -Parent
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
  $bmp.Save($Out, $codec, $ep)
  $g.Dispose(); $bmp.Dispose(); $img.Dispose()
} catch { Fail "convert failed: $($_.Exception.Message)" }

$kb = [int]((Get-Item $Out).Length / 1KB)
$sec = [int]((Get-Date) - $started).TotalSeconds
Write-Host "gen-paper-image: OK -> $Out (${w}x${h}, ${kb}KB, ${sec}s)"
exit 0
