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
  [int]$Quality = 82
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
function FirstSentence($s, $max) {
  # first sentence; if still long, cut at the last clause boundary (、) within $max - no ellipsis, so the image has no "..." artifacts
  $s = [string]$s
  $k = $s.IndexOf("。"); if ($k -gt 0) { $s = $s.Substring(0, $k) }
  if ($s.Length -gt $max) {
    $cut = $s.Substring(0, $max).LastIndexOf("、")
    $s = if ($cut -ge 12) { $s.Substring(0, $cut) } else { $s.Substring(0, $max) }
  }
  return $s
}
$boxes = @()
foreach ($c in $cats) {
  if (-not $c.text -or $c.text -eq "本日の更新なし") { continue }
  if ($pickCat -and $pickCat.Contains($c.label)) { continue }
  $boxes += ($c.label + "：" + (FirstSentence $c.text 42))
  if ($boxes.Count -ge 4) { break }
}
$boxText = ($boxes | ForEach-Object { "<<" + $_ + ">>" }) -join " "

# ---- prompt ----------------------------------------------------------------
$prompt = "Create ONE image with the built-in image generation (imagegen) capability: the front page of a Japanese newspaper, portrait 1024x1536, for a personal daily tech news briefing. " +
  "Masthead text exactly: デイリーブリーフィング. Date line exactly: $jpDate. " +
  "Style: cream newsprint paper, black ink typography, vermilion (朱色) accent for labels and rules, flat editorial illustrations with simple geometric icons, clean newspaper grid with thin rules. " +
  "Main story block labeled 今日の1本: headline exactly 「$pickTitle」 and subhead exactly: $pickReason Include a simple diagram or illustration that visualizes this story symbolically (e.g., a 3-step flow). " +
  "Lower section: short news boxes with these exact Japanese texts as their headlines (the << >> markers only delimit the texts; never draw them or any quotation marks around headlines): $boxText Each box may have a small flat illustration. " +
  "Render all Japanese text exactly as given, legibly. Use ONLY the provided text; do not invent additional headlines, facts, names, or numbers. " +
  "No brand logos, no real people, no photographs, no watermark. " +
  "Do not try to copy or move the file; the default save location is fine. Reply with only the absolute path of the saved PNG."
$prompt = ($prompt -replace '"', "'") -replace '[\r\n]+', ' '

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
