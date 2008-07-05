The scripts, esspecially the Makefile is taken from project scplugin, 
the Subversion Mac Finder plugin. 
http://scplugin.tigris.org/


Manfred Bergmann in 2006

------------------------------------------------------------------------------

build targets:
fetch				for fetching the current sword sources
build-release		for building a striped, optimized product (ppc only, SDK 10.2.8). includes fetch
build-release-fat	for building a striped, optimized product (universal binary). includes fetch
build-debug			for building a unstriped, unoptimized product (ppc only, SDK 10.2.8). includes fetch
build-debug-fat		for building a unstriped, unoptimized product (universal binary). includes fetch

After make has completed, there are several directories.
ppc_inst is the compiled and installed ppc version.
intel_inst is the compiled and installed intel version.
result_inst holds the compiled libraries which are copied to here after building.
it also holds includes and locales.d directories.

