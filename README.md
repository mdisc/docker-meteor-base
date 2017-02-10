# yoursco/meteor-base

This is a base docker image for our Meteor applications.

It installs Meteor and adds scripts for building your Meteor app and cleaning up Meteor and it's dependencies.

It makes a few assumptions about what inheriting images will do.

0. The meteor app must be added to `/home/meteor/src`
0. After adding the app, you must `RUN /usr/bin/build-app.sh`
0. After adding the app, you must `RUN /usr/bin/cleanup.sh`

It will start the app with `exec` mode, so your app will be running as PID 1 and can handle `SIGTERM`.
