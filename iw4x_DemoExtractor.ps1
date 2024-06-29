#global vars
$scriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$OutputDir = $scriptDir + "\Output"
$ModOutputDir = $OutputDir + "\Mods"

#get iw4x install directories
$GameRootDir = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | % { Get-ItemProperty $_.PsPath } | Where-object {$_.DisplayName -like "Call of Duty: Modern Warfare 2 (2009) - Multiplayer"}).installlocation

#get Demo directories
$DemoDirs = get-childitem $GameRootDir -recurse -Directory -filter "*demo*"

ForEach($DemoDir in $DemoDirs){
    
    #Set Output directory
    $ModName = $demodir.Parent.name
    $ModDir = $ModOutputDir + "\" + $ModName

    #create Output Directory if doesnt exist
    If(Test-Path $ModDir){
        Write-host "Found directory for $ModName" -ForegroundColor Green
    }Else{
        Write-host "Creating directory for $ModName..." -ForegroundColor green
        New-item -path $ModOutputDir -Name $ModName -ItemType Directory
    }
    
    
    $demos = gci $demodir.FullName -filter "*.json"
    Write-host "Extracting" $demos.count "demos for $ModName.. " -ForegroundColor Green

    $results = ForEach($DM13Json in $demos){

        #get Actual Demo File
        $DM13Item = Get-item -Path ($DM13Json.Fullname -replace ".json","")

        #extract Raw Json Data
        $obj = get-content $DM13Json.fullname | convertfrom-json 
        $obj | Add-Member -Name 'FileName' -Type NoteProperty -value $DM13Json.name 
        $obj | Add-Member -name 'DateTime' -type NoteProperty -value (([System.DateTimeOffset]::FromUnixTimeSeconds($obj.timestamp)).DateTime.ToLocalTime()).ToString("yyyy-MM-dd_HHmm")

        #Compose output name
        $finalOutput = $ModDir + "\" +  $obj.DateTime  +"_"+ $obj.author +"_"+ ($obj.mapname -replace "mp_","") +"_"+ $modname +".zip"

        #create compression parameteres
        $compressparam = @{
            Path = $DM13Item.FullName,$DM13Json.Fullname
            Compressionlevel = "fastest"
            DestinationPath = $finalOutput
        }    
        compress-archive @compressparam -Force
        II $Moddir
    }
}










