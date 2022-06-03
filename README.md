# NETCONF Stack Config/Compile/Build

## Running docker
`# docker run --name netconf-server -it -p 8830:830/tcp DOCKER_NAME`
**sysrepo daemon and netconf server will start on boot.**

    # sysrepo-plugind --verbosity 2 --debug & 
    # netopeer2-server

## Inside docker container
### If you want any notification, you can run:
`# ./sysrepo/build/examples/notif_subscribe_example oven`

### NETCONF CLI client:
`# netopeer2-cli`

### NETCONF CLI commands:
    netopeer2-cli > connect
    netopeer2-cli > user-rpc --content /root/oven-example/insert-food.xml
    netopeer2-cli > get-config --source running
    netopeer2-cli > edit-config --target running --config=/root/oven-example/oven-config.xml
    netopeer2-cli > get-config --source running
