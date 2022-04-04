function CheckFolderForHash {
    Param($ComputerFolder,
            $HashList)

    ##Gather List of Files in folders
    $File_list = New-Object System.Collections.ArrayList
    $folder_list = New-Object System.Collections.ArrayList
    foreach($Item in Get-ChildItem -path $ComputerFolder -force){
        if($item.Mode[0] -eq "d"){
            $folder_list.add($item.FullName) | Out-Null
            write-host $item.fullname
        }
        else{
            $File_list.Add($item.FullName) | Out-Null
            Write-Host $item.FullName
        }
    }
    while($folder_list){
        foreach($folder in $folder_list.ToArray()){
            foreach($item in Get-ChildItem -Path $folder -Force){
                if($item.Mode[0] -eq "d"){
                    $folder_list.add($item.FullName)
                }
                else{
                    $File_list.Add($item.FullName)
                }
            }
            $folder_list.Remove($folder)
        }
    }

    ## Compare Hash of files to Hashes given
    foreach($file in $File_list){
        $hash = Get-FileHash $file -ErrorAction SilentlyContinue
        if($HashList -contains $hash.Hash){
            Write-Host "`nHash is found!" $hash.Hash $hash.Path "`n"
            if((Read-Host -Prompt 'Continue? (Y/N)') -eq 'N'){
                break
            }
            else{
                continue
            }
        }
        else{
            write-host $hash.Hash $hash.Path
        }
    }
        
}