function showOS {
    # Build Numbers
    # https://gist.github.com/mxpv/2935584
    $OSData = Get-WmiObject Win32_OperatingSystem
    $BuildNumber = $OSData.BuildNumber
    $strVersion = $OSData.Version
    $strVersion = $strVersion.Replace( ".$BuildNumber", "" )
    $WinVer = [decimal]$strVersion
    if( $WinVer -lt 6.0 ){
        echo "not support vertion"
    }
    elseif(($WinVer -ge 6.0) -and ($WinVer -lt 6.1)){
        # 6.0
        echo "Windows Vista or Windows Server 2008"
    }
    elseif(($WinVer -ge 6.1) -and ($WinVer -lt 6.2)){
        # 6.1
        if ( $BuildNumber -eq 7600 ) {
            echo "Windows 7 or Windows Server 2008 R2"
        }
        else {
            echo "Windows 7 or Windows Server 2008 R2 SP1+"
        }
    }
    elseif(($WinVer -ge 6.2) -and ($WinVer -lt 6.3)){
        # 6.2
        echo "Windows 8 or Windows Server 2012"
    }
    elseif(($WinVer -ge 6.3) -and ($WinVer -lt 6.4)){
        # 6.3
        echo "Windows 8.1 or Windows Server 2012 R2"
    }
    else {
        echo "Windows 10 and later or Windows Server 2015 and later"
    }
}

function installSublimeText3 {
    param ($targetDir)

    $appName = "Sublime Text3"

    echo "- $appName"

    choco install SublimeText3 -y

    # Download fonts
    Set-Location $targetDir
    git clone https://github.com/urupiko/sublime.git Gitroot\sublime

    # link to settings
    $userDir = "$env:AppData\Sublime Text 3\Packages\User"
    if (-not(Test-Path -path $userDir)) {
      mkdir $userDir | out-null
    }
    cmd /c "mklink `"$userDir\Default (Windows).sublime-keymap`" `"$targetDir\Gitroot\sublime\User\Default (Windows).sublime-keymap`""
    cmd /c "mklink `"$userDir\Preferences.sublime-settings`" `"$targetDir\Gitroot\sublime\User\Preferences.sublime-settings`""
    cmd /c "mklink `"$userDir\Package Control.sublime-settings`" `"$targetDir\Gitroot\sublime\User\Package Control.sublime-settings`""
    cmd /c "mklink `"$userDir\insert_date.sublime-settings`" `"$targetDir\Gitroot\sublime\User\insert_date.sublime-settings`""

    # File Associations
    cmd /c assoc .txt=sublimefile
    cmd /c assoc .ini=sublimefile
    cmd /c assoc .c=sublimefile
    cmd /c assoc .cpp=sublimefile
    cmd /c assoc .rb=sublimefile
    cmd /c "ftype sublimefile=`"$env:programfiles\Sublime Text 3\sublime_text.exe`" `"%1`" %*"
}

function installSakura {
    param ($targetDir, $flag)

    $appName = "SakuraEditor"
    $appVersion = "2.3.0.0"

    echo "- $appName"
    $targetDir = Join-Path $targetDir $appName

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $false
        }
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "http://downloads.sourceforge.net/project/sakura-editor/sakura2/$appVersion/sakura2-3-0-0.zip"
    $outPath = Join-Path $targetDir "sakura.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath
    echo "    downloaded sakura editor"

    # Extract manifest file and sakura.exe.ini file
    $outPath = Join-Path $targetDir "QuickStartV2.zip"
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Disable multi user mode
    $outPath = Join-Path $targetDir "sakura.exe.ini"
    $data=Get-Content $outPath | % { $_ -replace "MultiUser=1","MultiUser=0" }
    $data | Out-File $outPath -Encoding Default

    # Generate sakura.ini
    $outPath = Join-Path $targetDir "sakura.exe"
    $p = Start-Process "$outPath" -PassThru
    taskkill /pid $p.Id | Out-Null
    Stop-Process -name sakura # this is needed for close all task

    # Setup macro
    $macroDir = Join-Path $targetDir "macro"
    mkdir $macroDir | out-null
    $dl = "http://ftp.vector.co.jp/35/01/2208/sacal100.lzh"
    $outPath = Join-Path $macroDir "sacal100.lzh"
     (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "lha" -ArgumentList "x `"$outPath`" -w=`"$macroDir`"" -Wait -NoNewWindow
    mv "$macroDir\readme.txt" "$macroDir\reamde_calc.txt"
    rm $outPath
    echo "    downloaded macro"

    # Edit sakura.ini
    $outPath = Join-Path $targetDir "sakura.ini"
    $targetDirDoubleDelim = $targetDir.Replace("\", "\\")
    $data=Get-Content $outPath `
        | % { $_ -replace "szMACROFOLDER=$targetDirDoubleDelim","szMACROFOLDER=$macroDir" } `
        | % { $_ -replace "bTab_RetainEmptyWin=1","bTab_RetainEmptyWin=0" } `
        | % { $_ -replace "bDispTOOLBAR=1","bDispTOOLBAR=0" } `
        | % { $_ -replace "bTaskTrayStay=1","bTaskTrayStay=0" } `
        | % { $_ -replace "bTaskTrayUse=1","bTaskTrayUse=0" } `
        | % { $_ -replace "KeyBind\[082\]=0057,0,0,30400,0,0,0,31143,0,W","KeyBind[082]=0057,0,0,31320,0,0,0,31143,0,W" } `
        | % { $_ -replace "KeyBind\[092\]=00ba,0,0,30612,0,30791,0,0,0,:","KeyBind[092]=00ba,0,0,30612,0,30791,0,31600,0,:" }

        $lnum = $(Select-String -pattern "\[Macro\]" -path $outPath).LineNumber -1
        $add_lines = `
            "`nFile[000]=calc.js`nName[000]=calc`nReloadWhenExecute[000]=0"
        If ($lnum -ne -1){
            $data[$lnum]=$data[$lnum]+$add_lines
        }
    $data | Out-File $outPath -Encoding UTF8

    # Download application icon
    $dl = "http://sakura.qp.land.to/?plugin=attach&refer=Customize%2FIcons&openfile=nplike_appicon.zip"
    $outPath = Join-Path $targetDir "nplike_appicon.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath
    echo "    downloaded app icon"

    # Download tool icon
    $dl = "http://sakura.qp.land.to/?plugin=attach&refer=Customize%2FIcons&openfile=784D%2B2_icons.zip"
    $outPath = Join-Path $targetDir "toolicon.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

   # Pin to taskbar
   Pin-Taskbar -Item "$targetDir\sakura.exe" -Action Pin 

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}


function installDotFiles {
    param ($targetDir)

    Set-Location $targetDir
    git clone https://github.com/urupiko/dotfiles.git Gitroot\dotfiles
}

function installPlatinumSearcher  {
    param ($targetDir, $binPath, $flag)

    $appName = "Pt"
    $appVersion = "2.1.0"
    # See : https://github.com/monochromegane/the_platinum_searcher/releases

    echo "- $appName"
    $targetDir = Join-Path $targetDir $appName

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $true
        }
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "https://github.com/monochromegane/the_platinum_searcher/releases/download/v2.1.0/pt_windows_amd64.zip"
    $outPath = Join-Path $targetDir "pt.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "e -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Create a symbolic link
    $ptExePath = "$targetDir\pt.exe"
    if (-not(Test-Path -path $ptExePath)) {
        Write-Host "  [ERROR] : Cannot find $ptExePathfor link target" -ForegroundColor Red
        return $false
    }
    cmd /c "mklink `"$binDir\pt.exe`"  `"$ptExePath`""

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}

function installOpenSSH  {
    param ($targetDir,  $flag)

    $appName = "OpenSSH"
    $appVersion = "f3c8418"
    # See : https://github.com/PowerShell/Win32-OpenSSH/releases/download/latest/OpenSSH-Win64.zip

    echo "- $appName"
    $targetDir = Join-Path $targetDir $appName

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $true
        }
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/latest/OpenSSH-Win64.zip"
    $outPath = Join-Path $targetDir "OpenSSH.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "e -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}


function installRekisa {
    param ($targetDir, $flag)

    $appName = "Rekisa"
    $appVersion = "0.50.012"

    echo "- $appName"
    $targetDir = Join-Path $targetDir $appName

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $false
        }
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "http://frozenlib.net/rekisa/archive/Rekisa-$appVersion.zip"
    $outPath = Join-Path $targetDir "rekisa.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "e -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath
    rmdir "$targetDir\Rekisa-*"

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}


function installSinkuSuperLite {
    param ($targetDir, $flag)

    $appName = "ShinkuSuperLite"
    $appVersion = "151101"

    echo "- $appName"
    $targetDir = Join-Path $targetDir $appName

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $false
        }
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "http://www.kurohane.net/archive/sinkusuperlite_$appVersion.zip"
    $outPath = Join-Path $targetDir "sinkusuperlite.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}

function installVifm {
    param ($targetDir, $binPath, $flag)

    $appName = "Vifm"
    $appVersion = "0.8.1"
    #check : http://sourceforge.net/projects/vifm/files/vifm-w64/

    echo "- $appName"
    $targetDir = Join-Path $targetDir $appName

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $false
        }
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "http://sourceforge.net/projects/vifm/files/vifm-w64/vifm-w64-se-0.8.1-binary.zip/download"
    $outPath = Join-Path $targetDir "vifm.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    if (-not(Test-Path -path $outPath)) {
        Write-Host "  [ERROR] : $appVersion" -ForegroundColor Red
        return $false
    }
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

#    Seems this color scheme is not supported on windows..
#    # Download color
#    $dl = "https://github.com/vifm/vifm-colors/raw/master/zenburn_1.vifm"
#    $colorDir = Join-Path $env:AppData "Vifm\colors"
#    $outPath = $colorDir + "\zenburn_1.vifm"
#    mkdir -p $colorDir
#    (new-object Net.WebClient).DownloadFile($dl, $outPath)    
#    if (-not(Test-Path -path $outPath)) {
#        Write-Host "  [ERROR] : failed to download color scheme $appVersion" -ForegroundColor Red
#         return $false
#    }

    # Remove top directory in the archive
    $tempDir = Join-Path (Split-Path $targetDir -parent) "__temp"
    mkdir $tempDir | out-null
    mv "$targetDir\*\*" "$tempDir"
    Remove-Item "$targetDir\*"
    mv "$tempDir\*" "$targetDir"
    Remove-Item $tempDir

    # Create a symbolic link
    $vifmExePath = "$targetDir\vifm.exe"
    if (-not(Test-Path -path $vifmExePath)) {
        Write-Host "  [ERROR] : Cannot find $vifmExePath for link target" -ForegroundColor Red
        return $false
    }
    cmd /c "mklink `"$binDir\vifm.exe`"  `"$vifmExePath`""

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}


function installVimKaoriya{
    param ($targetDir, $flag)

    $appName = "Vim"
    $appVersion = "7.4.1161"
    #check : http://www.kaoriya.net/news/

    echo "- $appName"
    $targetDir = Join-Path $targetDir $appName

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $false
        }
    }
    mkdir $targetDir | out-null

    # Download main package
    $dl = "http://files.kaoriya.net/goto/vim74w64"
    $outPath = Join-Path $targetDir "vim.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    if (-not(Test-Path -path $outPath)) {
        Write-Host "  [ERROR] : $appVersion" -ForegroundColor Red
         return $false
    }

    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Remove top directory in the archive
    $tempDir = Join-Path (Split-Path $targetDir -parent) "__temp"
    mkdir $tempDir | out-null
    mv "$targetDir\*\*" "$tempDir"
    Remove-Item "$targetDir\*"
    mv "$tempDir\*" "$targetDir"
    Remove-Item $tempDir

    # Set path as env var
    if (-not($env:Path.Contains("$targetDir"))) {
        [System.Environment]::SetEnvironmentVariable("PATH", $env:Path + ";$targetDir", "User")        
    }

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}


function installVirtualDub {
    param ($targetDir, $flag)

    $appName = "VirtualDub"
    $appVersion = "1.10.4"
    #check : http://sourceforge.net/projects/virtualdub/files/virtualdub-win/

    echo "- $appName"

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $false
        }
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "http://sourceforge.net/projects/virtualdub/files/virtualdub-win/1.10.4.35491/VirtualDub-1.10.4.zip/download"
    $outPath = Join-Path $targetDir "VirtualDub.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}


function installLeeyes {
    param ($targetDir, $flag)

    $appName = "Leeyes"
    $appVersion = "261"

    echo "- $appName"
    $targetDir = Join-Path $targetDir $appName

    if (Test-Path -path $targetDir) {
        if ($flag -eq "clear") {
            Remove-Item $targetDir -Recurse
        } else {
            echo "  [SKIP] : already installed"
            return $false
        }
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "http://www3.tokai.or.jp/boxes/leeyes/leeyes261.zip"
    $outPath = Join-Path $targetDir "leeyes.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "e -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Download susie plugin package
    $dl = "https://www.digitalpad.co.jp/~takechin/archives/spi32008.lzh"
    $outPath = Join-Path $targetDir "spi32008.lzh"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "lha" -ArgumentList "x `"$outPath`" -w=`"$targetDir`"" -Wait -NoNewWindow
    rm $outPath

    # Put version text
    $outPath = Join-Path $targetDir "version.txt"
    $appVersion | Out-File $outPath -Encoding UTF8
    Write-Host "  [INSTALLED] : $appVersion" -ForegroundColor Green
}

function installFonts {
    param ($fontPath)

    Write-Host "  installing - $fontPath"

    $FONTS = 0x14
    $objShell = New-Object -ComObject Shell.Application
    $objFolder = $objShell.Namespace($FONTS)
    $objFolder.CopyHere($fontPath)
}

function installFontArisaka {
    param ($targetDir)

    $fontName = "Arisaka"
    #check : http://myrica.estable.jp/

    echo "- Font: $fontName"
    $targetDir = Join-Path $targetDir $fontName

    if (Test-Path -path $targetDir) {
        Remove-Item $targetDir -Recurse
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "http://www.geocities.jp/osakaforwin/arisaka.zip"
    $outPath = Join-Path $targetDir "arisaka.zip"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Install fonts
    Set-Location "$targetDir\ARISAKA"
    Get-ChildItem *.ttf | %{installFonts $_.FullName}

    echo "  [INSTALLED]"
}

function installFontMyrica {
    param ($targetDir)

    $fontName = "Myrica"
    #check : http://myrica.estable.jp/

    echo "- Font: $fontName"
    $targetDir = Join-Path $targetDir $fontName

    if (Test-Path -path $targetDir) {
        Remove-Item $targetDir -Recurse
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "https://github.com/tomokuni/Myrica/raw/master/product/Myrica.7z"
    $outPath = Join-Path $targetDir "Myrica.7z"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    installFonts("$targetDir\Myrica.ttc")

    echo "  [INSTALLED]"
}

function installFontCica {
    param ($targetDir)

    $fontName = "Cica"
    #check : https://sv.btnb.jp/cica-font
    #remarks : powerline patched!

    echo "- Font: $fontName"
    $targetDir = Join-Path $targetDir $fontName

    if (Test-Path -path $targetDir) {
        Remove-Item $targetDir -Recurse
    }
    
    mkdir $targetDir | out-null

    # Download main package
    $dl = "https://sv.btnb.jp/wp-content/uploads/2015/08/Cica.zip"
    $outPath = Join-Path $targetDir "Cica.7z"
    (new-object Net.WebClient).DownloadFile($dl, $outPath)
    Start-Process "7za" -ArgumentList "x -o`"$targetDir`" -y `"$outPath`"" -Wait -NoNewWindow
    rm $outPath

    # Install fonts
    Set-Location "$targetDir\$fontName"
    Get-ChildItem *.ttf | %{installFonts $_.FullName}

    echo "  [INSTALLED]"
}

function installFontRictyDiminished {
    param ($targetDir)

    $fontName = "RictyDiminished"
    #check : https://github.com/yascentur/RictyDiminished

    echo "- Font: $fontName"
    $targetDir = Join-Path $targetDir $fontName

    if (Test-Path -path $targetDir) {
        Remove-Item $targetDir -Recurse
    }
    
    mkdir $targetDir | out-null

    # Download fonts
    Set-Location $targetDir
    git clone https://github.com/yascentur/RictyDiminished.git

    # Install fonts
    Set-Location "$targetDir\$fontName"
    Get-ChildItem *.ttf | %{installFonts $_.FullName}

    echo "  [INSTALLED]"    
}

function setRegistry( $RegPath, $RegKey, $RegKeyType, $RegKeyValue ){
    # Check if exists
    $Elements = $RegPath -split "\\"
    $RegPath = ""
    $FirstLoop = $True
    foreach ($Element in $Elements ){
        if($FirstLoop){
            $FirstLoop = $False
        }
        else{
            $RegPath += "\"
        }
        $RegPath += $Element
        if( -not (test-path $RegPath) ){
            md $RegPath
        }
    }

    # Check if key exists
    $Result = Get-ItemProperty $RegPath -name $RegKey -ErrorAction SilentlyContinue
    if( $Result -ne $null ){
        Set-ItemProperty $RegPath -name $RegKey -Value $RegKeyValue
    }
    else{
        New-ItemProperty $RegPath -name $RegKey -PropertyType $RegKeyType -Value $RegKeyValue
    }
    Get-ItemProperty $RegPath -name $RegKey
}

function changeSettingToShowExtension  {
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $RegKey = "HideFileExt"
    $RegKeyType = "DWord"
    $RegKeyValue = 0
    setRegistry $RegPath $RegKey $RegKeyType $RegKeyValue
}

function Pin-Taskbar([string]$Item = "",[string]$Action = ""){
    if($Item -eq ""){
        Write-Error -Message "You need to specify an item" -ErrorAction Stop
    }
    if($Action -eq ""){
        Write-Error -Message "You need to specify an action: Pin or Unpin" -ErrorAction Stop
    }
    if((Get-Item -Path $Item -ErrorAction SilentlyContinue) -eq $null){
        Write-Error -Message "$Item not found" -ErrorAction Stop
    }
    $Shell = New-Object -ComObject "Shell.Application"
    $ItemParent = Split-Path -Path $Item -Parent
    $ItemLeaf = Split-Path -Path $Item -Leaf
    $Folder = $Shell.NameSpace($ItemParent)
    $ItemObject = $Folder.ParseName($ItemLeaf)
    $Verbs = $ItemObject.Verbs()
    switch($Action){
        "Pin"   {$Verb = $Verbs | Where-Object {$_.Name -EQ "Pin to Tas&kbar"}}
        "Unpin" {$Verb = $Verbs | Where-Object {$_.Name -EQ "Unpin from Tas&kbar"}}
        default {Write-Error -Message "Invalid action, should be Pin or Unpin" -ErrorAction Stop}
    }
    if($Verb -eq $null){
        Write-Error -Message "That action is not currently available on this item" -ErrorAction Stop
    } else {
        $Result = $Verb.DoIt()
    }
}
