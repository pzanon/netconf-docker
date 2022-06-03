# NETCONF Stack Config/Compile/Build

## Running docker
`# docker run --name netconf-server -it -p 8830:830/tcp DOCKER_NAME`

## Inside docker container
### Start sysrepo daemon:
`# sysrepo-plugind --verbosity 2 --debug & `

### If you want any notification, you can run:
`# ./sysrepo/build/examples/notif_subscribe_example oven`

### Start netconf server:
`# netopeer2-server`

### First add a password to root user, remember this password you will need to use in CLI:
`# passwd`

### Start netconf client:
`# netopeer2-cli`

### Some CLI commands:
`netopeer2-cli > connect`

`netopeer2-cli > user-rpc --content /root/oven-example/insert-food.xml`

`netopeer2-cli > get-config --source running`

`netopeer2-cli > edit-config --target running --config=/root/oven-example/oven-config.xml`

`netopeer2-cli > get-config --source running`
