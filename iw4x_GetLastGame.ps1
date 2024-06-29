#global vars
$scriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$OutputDir = $scriptDir + "\Output"
$LGOutputDir = $OutputDir + "\LastGame"

#get iw4x install directories
$GameRootDir = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | % { Get-ItemProperty $_.PsPath } | Where-object {$_.DisplayName -like "Call of Duty: Modern Warfare 2 (2009) - Multiplayer"}).installlocation

If(Test-Path $LGOutputDir){
    Write-host "Found \LastGame Directory" -ForegroundColor Green
}Else{
    Write-host "Creating directory..." -ForegroundColor green
    New-item -path $OutputDir -Name "LastGame" -ItemType Directory
}
    


#get all demos
$allDemos = GCI $GameRootDir -Recurse -Filter "*.dm_13.json"

write-host "Found" $allDemos.Length "Demos..." -ForegroundColor yellow
$allDemos | select Name,CreationTime| sort CreationTime -Descending | Ft


#get latest Demos
$DM13Json = $alldemos | sort LastWriteTime | Select -last 1

$DM13Item = Get-item -Path ($DM13Json.Fullname -replace ".json","")

#extract Raw Json Data
$obj = get-content $DM13Json.fullname | convertfrom-json 
$obj | Add-Member -Name 'FileName' -Type NoteProperty -value $DM13Json.name 
$obj | Add-Member -name 'DateTime' -type NoteProperty -value (([System.DateTimeOffset]::FromUnixTimeSeconds($obj.timestamp)).DateTime.ToLocalTime()).ToString("yyyy-MM-dd_HHmm")


#Compose output name
$finalOutput = $LGOutputDir + "\" +  $obj.DateTime  +"_"+ $obj.author +"_"+ ($obj.mapname -replace "mp_","") +"_"+ $modname +".zip"

#create compression parameteres
$compressparam = @{
    Path = $DM13Item.FullName,$DM13Json.Fullname
    Compressionlevel = "fastest"
    DestinationPath = $finalOutput
}

$promptext = "Last game was "+ $obj.author + " on " + $obj.mapname +" at "+ $obj.dateTime +". Exporting game demo.."
write-host $promptext -foregroundColor green

compress-archive @compressparam -Force
Start-Sleep -Seconds 2
ii $LGOutputDir
Start-Sleep -Seconds 10
