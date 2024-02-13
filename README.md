# Basic RServer for the Vincent Lab  

* this repo originally resided at https://github.com/rserver , it was moved here on 2/12/2024

## Introduction  
This environment sets up the IDE and R-Packages needed to do analyses and reports for the Vincent Lab.  


## DockerHub link:  
https://hub.docker.com/repository/docker/benjaminvincentlab/rserver  


## What's with the rserver_handler.sh  
In our cluster environment, the rstudio server often doesn't terminate cleanly.  The leftover processes affect the binding of volumes for subsequent RServer containers. Additionally processes created by mclapply do not end with the RServer termination.  rserver_handler starts a monitor that periodically checks to see if the RServer is done running.  If so, it finds all of the processes in the RServer session id (sid) and sends them a sigterm. Then it terminates itself.  


## Building locally  
```bash
docker build -t benjaminvincentlab/rserver:3.6.1.0 .
```


## Running locally  
```bash
docker run -e PASSWORD=12qwaszx --rm -p 8787:8787 -v ~/Desktop:/home/rstudio   benjaminvincentlab/rserver:3.6.1.0 8787
```
Then direct browser to localhost:8787.  


## Tagging
w.x.y.z  
wxy is the version of R.  
z is the verion of this Dockerfile.  
