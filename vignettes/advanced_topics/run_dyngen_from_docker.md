Advanced: Running dyngen from a docker container
================

<!-- github markdown built using 
rmarkdown::render("vignettes/run_dyngen_from_docker.Rmd", output_format = rmarkdown::github_document())
-->

To ensure reproducibility, you can run dyngen in a docker container.
[dynverse/dyngen](https://hub.docker.com/r/dynverse/dyngen) contains all
necessary packages to run dyngen from start to finish. Ideally, you
would take a look at the latest tag published on [docker
hub](https://hub.docker.com/r/dynverse/dyngen) and replace any mentions
of `dynverse/dyngen` with `dynverse/dyngen:<latest digest>`, to make
sure you’re always using the exact same version of dyngen.

## Running the container

To run the container, you can use the following command.

``` sh
docker run --rm -p 127.0.0.1:8787:8787 -e DISABLE_AUTH=true -v `pwd`:/home/rstudio/workdir dynverse/dyngen
```

Keep this window open, and open up a browser and go to
[127.0.0.1:8787](127.0.0.1:8787). Open up the file `getting_started.R`
for a small example on how to run a dyngen simulation.

The command can be dissected as follows.

``` sh
docker run \

  # remove container after use
  --rm \
  
  # specify which port rstudio server uses
  -p 127.0.0.1:8787:8787 \
  
  # disable authentication because I'm lazy
  -e DISABLE_AUTH=true \
  
  # mount the current working directory in the rstudio home folder
  # so you will see it right away when rstudio starts
  -v `pwd`:/home/rstudio/workdir \
  
  # specify which container to run
  dynverse/dyngen
```

## Update the container

If a newer version of the container has been released, you can update it
by running the following command.

``` sh
docker pull dynverse/dyngen
```

## Building the container

To build this docker container from scratch, run the following command.

``` sh
docker build -t dynverse/dyngen -f docker/Dockerfile .
```

GITHUB\_PAT should be an environment variable corresponding to the
Personal Access Token created by following [this
tutorial](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).
