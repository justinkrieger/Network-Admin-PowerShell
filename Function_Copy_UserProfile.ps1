# Parameters: New computer, Old computer, and user profile name.
# USER MUST ALREADY HAVE PROFILE CREATED ON NEW COMPUTER
function Copy-UserProfile{
    Param(
    [String]$OldComputer,
    [String]$NewComputer,
    [String]$UserProfileName
    )

    # Test if Old computer available
    if(Test-Connection -ComputerName $OldComputer -Quiet -Count 1){
        Write-Host "$($OldComputer) found..." -ForegroundColor Green
    }
    else{
        Write-Host "$($OldComputer) is not available" -ForegroundColor Red
        Break
    }

    # Test if new computer available
    if(Test-Connection -ComputerName $NewComputer -Quiet -Count 1){
        Write-Host "$($NewComputer) found..." -ForegroundColor Green
    }
    else{
        Write-Host "$($NewComputer) is not available" -ForegroundColor Red
        Break
    }

    # Test if user profile exists on old computer
    if(Test-Path \\$OldComputer\c$\Users\$UserProfileName){
        Write-Host "$($UserProfileName) profile found..." -ForegroundColor Green
    }
    else{
        Write-Host "$($UserProfileName) profile not found" -ForegroundColor Red
        Break
    }
    
    $FoldersToCopy = @(
        'Desktop'
        'Downloads'
        'Favorites'
        'Documents'
        'Pictures'
        'Videos'
        'AppData\Local\Google'
    )

    $SourceRoot      = "\\$OldComputer\c$\Users\$UserProfileName"
    $DestinationRoot = "\\$NewComputer\c$\Users\$UserProfileName"

    foreach($Folder in $FoldersToCopy){
        $Source      = Join-Path -Path $SourceRoot -ChildPath $Folder
        $Destination = Join-Path -Path $DestinationRoot -ChildPath $Folder

        if( -not ( Test-Path -Path $Source -PathType Container)){
            Write-Warning "Could not find path `t$Source"
            continue
        }
        else{
            Robocopy.exe $Source $Destination /E /IS /NP /NFL
        }
    }
}