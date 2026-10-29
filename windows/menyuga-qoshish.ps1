# Hujjat Pro: Windows'da "Создать" menyusiga hujjat qo'shadi va .hujjat fayllarni ilovada ochadi.
# Faqat joriy foydalanuvchi uchun (HKCU), administrator huquqi kerak emas.
# Ishga tushirish: powershell -ExecutionPolicy Bypass -File menyuga-qoshish.ps1

$label   = "Word hujjati (Hujjat Pro)"
$progId  = "HujjatPro.Document"
$iconDir = Join-Path $env:LOCALAPPDATA "HujjatPro"
$icon    = Join-Path $iconDir "hujjat.ico"

# Chrome o'rnatgan Hujjat Pro ilovasini topamiz (fayl ochish buyrug'i)
$cmd = $null
Get-ChildItem "HKCU:\Software\Classes" | Where-Object { $_.PSChildName -like "Chrome.*" } | ForEach-Object {
  $c = Join-Path $_.PSPath "shell\open\command"
  if (Test-Path $c) {
    $v = (Get-ItemProperty $c).'(default)'
    if ($v -like "*Hujjat Pro.exe*") { $cmd = $v }
  }
}
if (-not $cmd) {
  Write-Host "Hujjat Pro ilovasi topilmadi. Avval https://word-uz.github.io saytidan 'O'rnatish' tugmasi bilan o'rnating." -ForegroundColor Red
  exit 1
}

if (-not (Test-Path $icon)) { Write-Host "Ikonka topilmadi: $icon" -ForegroundColor Yellow }

$root = "HKCU:\Software\Classes"
New-Item -Path "$root\.hujjat" -Force | Out-Null
Set-Item -Path "$root\.hujjat" -Value $progId
New-ItemProperty -Path "$root\.hujjat" -Name "Content Type" -Value "application/x-hujjat" -Force | Out-Null
New-Item -Path "$root\.hujjat\ShellNew" -Force | Out-Null
New-ItemProperty -Path "$root\.hujjat\ShellNew" -Name "NullFile" -Value "" -Force | Out-Null

New-Item -Path "$root\$progId" -Force | Out-Null
Set-Item -Path "$root\$progId" -Value $label
New-Item -Path "$root\$progId\DefaultIcon" -Force | Out-Null
Set-Item -Path "$root\$progId\DefaultIcon" -Value "$icon,0"
New-Item -Path "$root\$progId\shell\open\command" -Force | Out-Null
Set-Item -Path "$root\$progId\shell\open" -Value "Ochish"
Set-Item -Path "$root\$progId\shell\open\command" -Value $cmd

# "Создать" menyusi keshini yangilash
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Discardable\PostSetup\ShellNew" -Name "Classes" -ErrorAction SilentlyContinue

# Explorer'ga o'zgarish haqida xabar berish (ikonkalar yangilanadi)
Add-Type -Namespace W -Name S -MemberDefinition '[DllImport("shell32.dll")] public static extern void SHChangeNotify(int e, int f, System.IntPtr a, System.IntPtr b);'
[W.S]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)

Write-Host "Tayyor: o'ng tugma -> Создать -> '$label'" -ForegroundColor Green
