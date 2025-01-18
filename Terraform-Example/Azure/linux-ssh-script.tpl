cat << EOF >> ~/.ssh/config 

#from cat ~/.ssh/config
Host ${hostname}
    HostName ${hostname}
    User ${user}
    IdentifyFIle ${identifyfile}
EOF