This is a collection of Powershell scripts for remote admin actions on an AD network

1. Clean up user data from AD computers
    Removes excess user data from a list of AD computers. The script goes into each computer to see the amount of free space, if
    the free space is less than 3% then it will initiate removing user data. First it uses quser to see what user is currently
    logged so that it doesnt delete files that are being used. Then it logs out all other users on the computer. 
    The user folders it clears out are: 
    
      \AppData\Roaming\Microsoft\Teams\*
      \AppData\Local\Microsoft\Office\15.0\Lync\*
      \AppData\Local\Temp\*
      \Downloads\*
      \AppData\Local\Microsoft\Outlook\*.ost
      \AppData\Local\Google\Chrome\User Data\Default\*
      
    The script will then clear out the CCM cache. The limit of the number of computers to clear out at one time is currently set
    to 50 but can be changed. Each time a computer is cleared, it rechecks the disk size and stores the results into an array
    that is outputted at the end
     
2. Collect computer info
    Collects information about a computer that is on the network, and will also put monitor information. The following is what
    information is gathered form a computer:
    
      Computer Name
      IP Address
      Status (online or offline)
      Location from AD
      Manufacturer
      Model
      Last user to logon
      When computer AD object Created
      Monitor manufacturer/model for up to 4 monitors
      
    Once it finishes running through each computer in the list from AD, the script outputs a screen with the information on it 
    and also saves a .csv file in the current directory.
    
3. Function_checkfolderforhash
    Searches through a computer folder for a specified hash. Requires designation of Folder to search and Hash to find.
    
4. Function_Copy_UserProfile
    Copies users profile from one computer to another. Requires that the user has already logged into the new computer.
    
5. Function_Get_DiskUsage
    Retuns an array containing the space in GB left on the C drive and a percentage of space available. Can take a list of 
    computer names.
    
6. Remove_old_users_oneliner
    Removes user profiles for users that have not logged into the computer in over 30 days.
    
7. Unlock user account every 60 seconds
    Unlocks a users AD account every 60 seconds. Runs until script is stopped.
