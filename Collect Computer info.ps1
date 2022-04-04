function get-monitors2{
    $computerMonitors = Get-CimInstance -Namespace root\wmi -ClassName wmimonitorid -ComputerName $args[0] |
  select @{n='Computer'; e='PSComputerName'}, 
         @{n='Manufacturer'; e={[System.Text.Encoding]::ASCII.GetString($_.ManufacturerName)}}, 
         @{n='ProductCode'; e={[System.Text.Encoding]::ASCII.GetString($_.ProductCodeID)}}, 
         @{n='Serial Number'; e={[System.Text.Encoding]::ASCII.GetString($_.SerialNumberID)}}, 
         @{n='Model Name'; e={[System.Text.Encoding]::ASCII.GetString($_.UserFriendlyName)}}
    
    return $computerMonitors
}

function get-bios{
    $bios_info = Get-WmiObject -Class win32_computersystem -ComputerName $args[0]
    return $bios_info
}


$AD_Computers = "User Get-ADcomputers to get an array of all your AD computers"
$Computer_Array = New-Object System.Collections.ArrayList



foreach($Computer in $AD_Computers){
    $Tempobject = [PScustomobject]@{
        'Computer Name' = $Computer.Name
        'IP Address' = $Computer.IPv4Address
        'Status' = $null
        'Location' = $Computer.Description
        'Manufacturer' = $null
        'Model' = $null
        'Last logon' = [datetime]::FromFileTime($computer.lastLogon).toString('g')
        'Created' = $Computer.whenCreated
        'Monitor 1' = $null
        'Monitor 2' = $null
        'Monitor 3' = $null
        'Monitor 4' = $null
    }
    if(Test-Connection -ComputerName $Computer.Name -Count 1 -Quiet -ErrorAction SilentlyContinue){
        $monitors = get-monitors2 $computer.Name
        $bios = get-bios $Computer.Name
        $Tempobject.Status = $true
        $tempobject.'Monitor 1' = "$($Monitors[0].'Model Name') - $($Monitors[0].'Serial Number')"
        $tempobject.'Monitor 2' = "$($Monitors[1].'Model Name') - $($Monitors[1].'Serial Number')"
        $tempobject.'Monitor 3' = "$($Monitors[2].'Model Name') - $($Monitors[2].'Serial Number')"
        $tempobject.'Monitor 4' = "$($Monitors[3].'Model Name') - $($Monitors[3].'Serial Number')"
        $Tempobject.Manufacturer = $bios.Manufacturer
        $Tempobject.Model = $bios.Model
    }
    $Computer_Array.Add($Tempobject) | Out-Null
    Write-Host $Tempobject.'Computer Name' ($counter += 1)
}
$Computer_Array | Out-GridView
$Computer_Array | Export-Csv .\Computer_info.csv