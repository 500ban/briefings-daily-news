# cowork/scripts/paper-text.ps1
# Shared headline helpers for the newspaper-style hero image (dot-sourced by
# gen-paper-image.ps1 and render-card.ps1). Turns the first sentence of a category
# summary into a short 体言止め headline without cutting inside words.

function TrimEnding($frag) {
  # drop conjunctive / particle endings so the fragment reads as 体言止め (2 passes:
  # e.g. 「準備していると報」→「準備している」→「準備」)
  $endings = '(と報告|と報|と発表|と述べ|と説明|と指摘|している|しており|ており|ている|いる|になった|となった|なった|であり|であるが|しながら|ながら|したが|だが|ので|ため|つつ|から|より|され|して|受けて|受け|向けて|向け|通じて|通じ|踏まえて|踏まえ|含めて|含め|加えて|加え|巡り|めぐり|対して|対し|伴い|応じて|応じ|超えて|超え|続けて|続け|進めて|進め|広げて|広げ|始めて|始め|求めて|求め|認めて|認め|高めて|高め|強めて|強め|迎えて|迎え|控えて|控え|備えて|備え|変えて|変え|与えて|与え|抑えて|抑え|整えて|整え|据えて|据え|された|した|だった|する|なる|ある|し|て|た|が|で|に|を|と|へ|は|も|の)$'
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
  if ($s.Length -le $max) {
    # whole sentence fits: drop one sentence-final verb ending (「公表した」→「公表」) unless that leaves a bad stem
    $t = [regex]::Replace($s, '(された|している|ている|になった|となった|した|する|だった|である)$', '')
    $t = [regex]::Replace($t, '(に|と|を|が|は)$', '')
    if ($t.Length -ge 8 -and -not $t.EndsWith('っ')) { return $t }
    return $s
  }
  $hard = $s.Substring(0, $max)
  $cands = @()
  $cut = $hard.LastIndexOf("、")
  if ($cut -ge 12) { $cands += (TrimEnding (CleanCut $s.Substring(0, $cut) $s)) }
  $cands += (TrimEnding (CleanCut $hard $s))
  foreach ($c in $cands) { if ($c.Length -ge 18) { return $c } }
  foreach ($c in $cands) { if ($c.Length -ge 8) { return $c } }
  return $hard
}
