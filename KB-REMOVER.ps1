If (!(SYSTEMINFO.exe | findstr KB5000802)) {
        If (!(SYSTEMINFO.exe | findstr KB5000808)) {
        exit
        }
    }
Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::OK
$MessageIcon = [System.Windows.MessageBoxImage]::WARNING
$MessageBody = "Votre ordinateur devra redémarrer après une mise à niveau importante, enregistrer votre travail et cliquer sur OK. Une fois que vous aurez cliqué sur OK, le processus démarrera. Veuillez patienter pour une dizaine de minutes. Merci"
$MessageTitle = "!IMPORTANT! Soutien technique Savoura"
 
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

Stop-Service wuauserv 
$pause = (Get-Date).AddDays(7)
$pause = $pause.ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ssZ" )
$pause_start = (Get-Date)
$pause_start = $pause_start.ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ssZ" )
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseUpdatesExpiryTime' -Value $pause                                                 
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseFeatureUpdatesStartTime' -Value $pause_start
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseFeatureUpdatesEndTime' -Value $pause
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseQualityUpdatesStartTime' -Value $pause_start
Set-itemproperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseQualityUpdatesEndTime' -Value $pause
Stop-Service wuauserv

$packagenames = 'Package_for_RollupFix~31bf3856ad364e35~amd64~~19041.867.1.8',
                'Package_for_RollupFix~31bf3856ad364e35~amd64~~18362.1440.1.7' -join '|'
                
$update = (DISM /Online /Get-Packages | Select-String $packagenames).matches.value

if($update){
    DISM.exe /Online /Remove-Package /PackageName:$update /quiet /norestart /LogPath:c:\windows\temp\updateremoval.log /LogLevel:3
}

shutdown /r /t 10
