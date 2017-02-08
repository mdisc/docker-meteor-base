# yoursco/meteor-base

This is a base docker image for our Meteor applications.

This image expects your meteor app to be in the same directory you give to `docker build`. If your meteor app lives in a different directory, you can define a `METEOR_APP_PATH` build argument with the relative path from where you are running `docker build`, like this:

```bash
docker build . --build-args METEOR_APP_PATH=./app
```

Also, this image is built with the intention that you'll install other stuff via apt-get, so we don't clean up after ourselves. Adding a line like this to your child Dockerfile should help:

```
RUN apt-get clean && \
	rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
```
