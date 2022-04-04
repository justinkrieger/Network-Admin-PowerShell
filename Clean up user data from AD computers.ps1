#Functions
function get-computerMemory{
    param (
        $ComputerName
    )

    $Memory = Get-WmiObject -Class win32_logicaldisk -ComputerName $ComputerName | where DeviceID -EQ 'C:'
    if($Memory -eq $null){
        return $null
    }
    else{
        return $Memory
    }
}
function clear-computerMemory{
    param (
        $ComputerName
    )

    $LoggedIn = Get-WmiObject –ComputerName $ComputerName –Class Win32_ComputerSystem | Select-Object UserName
}
function logoff-inactiveUsers{
    param (
        $computerName
    )

    $sessions = (quser /server:$computerName) -split "\n" -replace '\s\s+', ';' | convertfrom-csv -Delimiter ';'
    $inactiveUsers = @()
    $activeUser = @()
    foreach($session in $sessions){
        if($session.STATE -eq 'Active'){
            $activeUser += $session.USERNAME
        }
        elseif($session.ID -eq 'Disc'){
            $inactiveUsers += $session
            logoff $session.SESSIONNAME /server:$computerName
        }
    }
    return $activeUser
}
function remove-excessUserData{
    param (
        $computerName,
        $ExceptUser
    )

    $Users = (Get-ChildItem -path "\\$($computerName)\c$\Users").Name

    foreach($user in $Users){
        if($ExceptUser -contains $user){
            continue
        }
        Get-ChildItem "\\$($computerName)\c$\Users\$($user)\AppData\Roaming\Microsoft\Teams\*" -ErrorAction SilentlyContinue | ForEach{Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
        Get-ChildItem "\\$($computerName)\c$\Users\$($user)\AppData\Local\Microsoft\Office\15.0\Lync\*" -ErrorAction SilentlyContinue | ForEach{Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
        Get-ChildItem "\\$($computerName)\c$\Users\$($user)\AppData\Local\Temp\*" -ErrorAction SilentlyContinue | ForEach{Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
        Get-ChildItem "\\$($computerName)\c$\Users\$($user)\Downloads\*" -ErrorAction SilentlyContinue | ForEach{Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
        Get-ChildItem "\\$($computerName)\c$\Users\$($user)\AppData\Local\Microsoft\Outlook\*.ost" -ErrorAction SilentlyContinue | ForEach{Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
        Get-ChildItem "\\$($computerName)\c$\Users\$($user)\AppData\Local\Google\Chrome\User Data\Default\*" -ErrorAction SilentlyContinue | where{($_.Name -ne 'Bookmarks') -and ($_.Name -ne 'Bookmarks.bak')} | ForEach{Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
    }
}


#Get results list ready
$Results = @()

#Get List of all location computers
Write-Host 'Collecting  computers...'
$ComputerList = "User Get-ADcomputers to get an array of all your AD computers"
Write-Host $ComputerList.Count 'computers collected'


foreach($Computer in $ComputerList){
    write-host -NoNewline $Computer '...'

    #If computer is not there, continue
    if(!(Test-Connection -ComputerName $Computer -Count 1 -Quiet)){
        write-host 'down'
        continue
    }
    Write-Host -NoNewline ' up ...'


    #If computer has more than 10% memory, continue
    $Harddrive = get-computerMemory -ComputerName $Computer
    $Freespace = [math]::Round((($Harddrive.FreeSpace + 0.0001) / $Harddrive.Size),2)
    if($Freespace -gt 0.05){
        Write-Host "freespace $($Freespace)"
        continue
    }
    Write-Host -NoNewline "freespace $($Freespace) ..."


    #Logoff inactive users and get active user
    $ConsoleUser = logoff-inactiveUsers -computerName $Computer
    Write-Host -NoNewline "$($ConsoleUser) ..."


    #Delete User files
    Write-Host -NoNewline "Removing files ..."
    remove-excessUserData -computerName $Computer -ExceptUser $ConsoleUser

    #Delete CCM Cache (Script directly from Configuration Manager)
    Write-Host -NoNewline "Removing CCM cache ..."
    Invoke-Command -ComputerName $Computer -ScriptBlock{
        $RM     = New-Object -ComObject UIResource.UIResourceMgr
        $Cache  = $RM.GetCacheInfo()
        $Cache.GetCacheElements() | ForEach-Object {$Cache.DeleteCacheElement($_.CacheElementId)}
    }

    #Get new memory
    $NewHarddrive = get-computerMemory -ComputerName $Computer
    $GBfree = [math]::round((($NewHarddrive.Freespace-$Harddrive.FreeSpace) / 1073741824),2)
    write-host "Done! $($GBfree) GB cleared"
    
    #if freed equal to 0
    if($GBfree -eq 0){
        continue
    }

    $Results += [pscustomobject]@{
        computer = $Computer 
        free = $GBfree
        }

    if($Results.Count -eq 50){
        break
    }
}

$Results | Out-GridView
