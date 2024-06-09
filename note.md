# This is some notes regarding my Linux settings.

## The problem with running Chrome, Github-dektop, ...

One way is to add a this commend in /etc/environment

sudo vim /etc/environment

add following this:
export LIBVA_DRIVER_NAME=disable

source /etc/environment