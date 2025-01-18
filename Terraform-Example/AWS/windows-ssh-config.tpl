add-content -path c:/users/raplima/.ssh/config -value @'

#from cat ~/.ssh/config
Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentifyFIle ${identifyfile}
'@