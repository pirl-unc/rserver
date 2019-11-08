# Basic RServer for the Vincent Lab

## What's with the rserver_handler.sh
In our cluster environment, the rstudio server often doesn't terminate cleanly.  The leftover processes affect the binding of volumes for subsequent RServer containers. Additionally processes created by mclapply do not end with the RServer termination.  rserver_handler starts a monitor that periodically checks to see if the RServer is done running.  If so, it finds all of the processes in the RServer session id (sid) and sends them a sigterm. Then it terminates itself.



## Building locally
```bash
docker run -e PASSWORD=12qwaszx --rm -p 8787:8787   -v ~/Desktop:/home/rstudio   bgvlab/rserver:3.6.1.0 8787
```


## Running locally
```bash
docker build -t bgvlab/rserver:3.6.1.0 .
```