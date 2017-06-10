iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

$major = [Environment]::OSVersion.Version.Major
$minor = [Environment]::OSVersion.Version.Minor
if ($major -eq 6 -and $minor -eq 1) {
	# Win7
##	choco install microsoftsecurityessentials -y
	choco install dotnet4.5 -y
	choco install powershell -y
}

# PSReadLine is installed by default on Windows 10
# (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
# Install-Module PSReadLine # needs restart

choco install 7zip.commandline -y
choco install lha -y
## ok to skip
# choco install msys2 -y
## choco install cygwin -y -o -ia "-q -N -R C:\ChocoApps\cygwin -l C:\ChocoApps\cygwin\packages --packages wget -s http://ftp.iij.ad.jp/pub/cygwin/"
choco install conemu -y
choco install git -y
choco install sourcetree -y
choco install vim -y
choco install peco -y
choco install GoogleChrome -y
# choco install curl
# choco install BeyondCompare
## choco install ruby -y -ia "/dir=C:\ChocoApps\ruby"
## choco install mpc-hc

$targetDir = "C:\Urupiko"
if (-not(Test-Path -path $targetDir)) {
  mkdir $targetDir | out-null
}

# Setup bin path
$binDir = Join-Path $targetDir "bin"
if (-not(Test-Path -path $binDir)) {
  mkdir $binDir | out-null
}
if (-not($env:Path.Contains($binDir))) {
   [System.Environment]::SetEnvironmentVariable("PATH", $env:Path + ";$binDir", "User")        
}  

# Workaround for restart the process
if (-not($env:Path.Contains("$env:programfiles\Git\bin"))) {
  $env:Path += ";$env:programfiles\Git\bin"
}

. .\install.ps1
installFontMyrica $(Join-Path $targetDir "Fonts")
installFontRictyDiminished $(Join-Path $targetDir "Fonts")
installFontCica $(Join-Path $targetDir "Fonts")
installFontArisaka $(Join-Path $targetDir "Fonts")
changeSettingToShowExtension

Pin-Taskbar -Item "C:\Program Files\Internet Explorer\iexplore.exe" -Action Unpin
Pin-Taskbar -Item "C:\Program Files (x86)\Windows Media Player\wmplayer.exe" -Action Unpin

installSakura $targetDir
installRekisa $targetDir
installSublimeText3 $targetDir
installDotFiles $targetDir
installVifm $targetDir $binDir
installPlatinumSearcher $targetDir $binDir
installOpenSSH $targetDir
# installVimKaoriya $targetDir

# disable unnecessary windows features 
# How to confirm feature name : dism /online /get-features | more
$feature_list = @(
	"Printing-XPSServices-Features", "Xps-Foundation-Xps-Viewer", "TabletPCOC",
	"OpticalMediaDisc", "MediaCenter", "FaxServicesClientPackage", "WindowsGadgetPlatform",
	"Minesweeper", "Internet Spades",  "Internet Backgammon", "Internet Checkers", 
	"Internet Games", "Shanghai", "Chess", "PurblePlace", "FreeCell", "Hearts",
	"SpiderSolitaire", "More Games", "InboxGames"
)
foreach($feature in $feature_list){
  Write-Host "Disabling : $feature"  -ForegroundColor Green
  dism /online /disable-feature /norestart /featurename:$feature
}

choco install launchy -y

#choco install googledrive -y # manual install or unnecessary?
#del "$env:Public\Desktop\Google Docs.lnk"
#del "$env:Public\Desktop\Google Sheets.lnk"
#del "$env:Public\Desktop\Google Slides.lnk"
