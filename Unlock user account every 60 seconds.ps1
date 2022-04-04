$UserName = 'Smith, John'
$Domain   = 'OU=Users, DC=Company, DC=Domain'

while($True){
    $User = Get-ADUser -filter {Name -like $UserName} -SearchBase $Domain -Properties *
    if($User.Lockedout -eq $True){
        Unlock-ADAccount -Identity $User.DistinguishedName
        $Time = Get-Date -Format "HH:mm:ss"
        write-host "Account unlocked $Time"
    }
    start-sleep 60
}