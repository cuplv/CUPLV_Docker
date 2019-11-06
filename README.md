A docker container with common CUPLV dependencies.

Build:
=====
./build.sh

Push:
=====
Log into docker with username and password
(TODO: move this to cuplv org on dockerhub)
./push.sh

To use:
=====
Create your own docker file and add:
```
FROM shawnmeier/cuplv_docker:1
```
