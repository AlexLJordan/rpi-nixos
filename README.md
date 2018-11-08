# rpi-nixos
The configurations for my raspberry pi with nixos.

# radicale users
install the htpasswd program by installing apacheHttpd (or something like that)
and execute htpasswd like this:

`htpasswd -B -c filepath username` for creating the file

`htpasswd -B filepath username` when there is already a file present
