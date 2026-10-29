# Hujjat Pro yozuvini "Создать" menyusidan va .hujjat bog'lanishini olib tashlaydi.
# Ishga tushirish: powershell -ExecutionPolicy Bypass -File menyudan-olib-tashlash.ps1
Remove-Item -Path "HKCU:\Software\Classes\.hujjat" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\Software\Classes\HujjatPro.Document" -Recurse -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Discardable\PostSetup\ShellNew" -Name "Classes" -ErrorAction SilentlyContinue
Add-Type -Namespace W -Name S -MemberDefinition '[DllImport("shell32.dll")] public static extern void SHChangeNotify(int e, int f, System.IntPtr a, System.IntPtr b);'
[W.S]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
Write-Host "Olib tashlandi." -ForegroundColor Green
