# Hujjat Pro: Windows'da "Создать" menyusiga hujjat qo'shadi va .hujjat fayllarni ilovada ochadi.
# Faqat joriy foydalanuvchi uchun (HKCU), administrator huquqi kerak emas.
# Ishga tushirish: powershell -ExecutionPolicy Bypass -File menyuga-qoshish.ps1

$label   = "Word hujjati (Hujjat Pro)"
$progId  = "HujjatPro.Document"
$iconDir = Join-Path $env:LOCALAPPDATA "HujjatPro"
$icon    = Join-Path $iconDir "hujjat.ico"

# Chrome o'rnatgan Hujjat Pro ilovasini topamiz (fayl ochish buyrug'i)
$cmd = $null
# avval Chrome .hujjat uchun ro'yxatga olgan dasturni olamiz (ilovaning yangi versiyasi)
$ow = Get-Item "HKCU:\Software\Classes\.hujjat\OpenWithProgids" -ErrorAction SilentlyContinue
if ($ow) { foreach ($p in $ow.Property) {
  $c = "HKCU:\Software\Classes\$p\shell\open\command"
  if (Test-Path $c) { $v = (Get-Item $c).GetValue(""); if ($v -like "*Hujjat Pro*.exe*") { $cmd = $v } }
} }
if (-not $cmd) { Get-ChildItem "HKCU:\Software\Classes" | Where-Object { $_.PSChildName -like "Chrome.*" } | ForEach-Object {
  $c = Join-Path $_.PSPath "shell\open\command"
  if (Test-Path $c) {
    $v = (Get-ItemProperty $c).'(default)'
    if ($v -like "*Hujjat Pro*.exe*") { $cmd = $v }
  }
} }
if (-not $cmd) {
  Write-Host "Hujjat Pro ilovasi topilmadi. Avval https://word-uz.github.io saytidan 'O'rnatish' tugmasi bilan o'rnating." -ForegroundColor Red
  exit 1
}

if (-not (Test-Path $icon)) { Write-Host "Ikonka topilmadi: $icon" -ForegroundColor Yellow }

$root = "HKCU:\Software\Classes"
# kalit bo'lmasa yaratadi; borini o'chirib yubormaydi (New-Item -Force ichidagi hamma narsani o'chiradi)
function Ensure-Key($k) { if (-not (Test-Path $k)) { New-Item -Path $k -Force | Out-Null } }
Ensure-Key "$root\.hujjat"
Set-Item -Path "$root\.hujjat" -Value $progId
New-ItemProperty -Path "$root\.hujjat" -Name "Content Type" -Value "application/x-hujjat" -Force | Out-Null
Ensure-Key "$root\.hujjat\ShellNew"
New-ItemProperty -Path "$root\.hujjat\ShellNew" -Name "NullFile" -Value "" -Force | Out-Null
New-ItemProperty -Path "$root\.hujjat\ShellNew" -Name "IconPath" -Value "$icon,0" -Force | Out-Null

# "Открыть с помощью" ro'yxatiga Microsoft Word'ni ham qo'shamiz (.hujjat ichida haqiqiy .docx bor)
if (Test-Path "Registry::HKEY_CLASSES_ROOT\Word.Document.12") {
  Ensure-Key "$root\.hujjat\OpenWithProgids"
  New-ItemProperty -Path "$root\.hujjat\OpenWithProgids" -Name "Word.Document.12" -Value "" -PropertyType String -Force | Out-Null
}

Ensure-Key "$root\$progId"
Set-Item -Path "$root\$progId" -Value $label
Ensure-Key "$root\$progId\DefaultIcon"
Set-Item -Path "$root\$progId\DefaultIcon" -Value "$icon,0"
Ensure-Key "$root\$progId\shell\open\command"
Set-Item -Path "$root\$progId\shell\open" -Value "Ochish"
Set-Item -Path "$root\$progId\shell\open\command" -Value $cmd

# "Создать" menyusi keshini yangilash
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Discardable\PostSetup\ShellNew" -Name "Classes" -ErrorAction SilentlyContinue

# Explorer'ga o'zgarish haqida xabar berish (ikonkalar yangilanadi)
Add-Type -Namespace W -Name S -MemberDefinition '[DllImport("shell32.dll")] public static extern void SHChangeNotify(int e, int f, System.IntPtr a, System.IntPtr b);'
[W.S]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)

Write-Host "Tayyor: o'ng tugma -> Создать -> '$label'" -ForegroundColor Green
