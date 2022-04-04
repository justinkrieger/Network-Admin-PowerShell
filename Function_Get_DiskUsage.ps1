# Parameters: ComputerName - Use computer name if computer name DNS resolvable, else use IP address.
function Get-DiskUsage{
    Param(
        [Parameter()]
        $ComputerName
    )
    $MemoryArray = New-Object System.Collections.ArrayList

    foreach($Computer in $ComputerName){

        if( -not (Test-Connection -ComputerName $Computer -Quiet -Count 1)){

            Write-Host "$($Computer) is not available" -ForegroundColor Red
            continue
        }

        # Get disk information
        $CDrive = Get-WmiObject -Class win32_logicaldisk -ComputerName $Computer | where DeviceID -EQ 'C:'

        $FreeSpace = [math]::Round(($CDrive.FreeSpace/1073741824), 2)
        $DiskUsage = 100 - [math]::Round(($CDrive.Freespace / $CDrive.Size)*100,2)

        $TempObject = [pscustomobject]@{
            'ComputerName' = $Computer
            'Freespace GB' = $FreeSpace
            'Disk Usage %' = $DiskUsage
        }
        $MemoryArray.add($TempObject) | out-null
    }
    return $MemoryArray
}