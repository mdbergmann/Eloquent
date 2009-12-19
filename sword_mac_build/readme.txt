Building sword library for MacSword:

- make a symlink for libtoolize:
ln -s /usr/bin/glibtoolize /usr/bin/libtoolize
- call one of the Build*.sh scripts either for a point release or SVN trunk.
parameters can be: "fat"|"intel"|"ppc", "debug"|"release"
- call CreateUniversalBinarySWORDUtilities.sh

