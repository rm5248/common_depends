# Common Dependencies

Common dependencies that I use in my projects.

# VCPKG scripts

checkout the vcpkg-scripts directory for scripts that will:

* Find ZIP files in the cache that contain a file named <x>

# Jenkins

The `Jenkinsfile` builds the dependencies on Windows (`windows11` node) and on
Linux (the built-in node).  The Linux build runs `linux-build.sh` in a
throwaway pbuilder chroot (`pbuilder execute`) created from
`/var/cache/pbuilder/base-trixie-amd64.tgz`.  That script installs the system
packages with `linux-depends.sh` and then builds the packages with vcpkg as the
Jenkins user.  The workspace and the vcpkg binary cache
(`<workspace>@vcpkg-cache`) are bind-mounted into the chroot.

The `jenkins` user needs passwordless sudo for `pbuilder`.
