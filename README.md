# `cargo-for-arm`

> Docker container that builds cargo for ARM on an x86_64 host using QEMU user emulation

This is one of the possible ways to build cargo for ARM on an x86_64 host, the other being cross
compilation (as in `cargo build --target armv7-unknown-linux-gnueabihf`).

## Overview

This approach does the following:

- Fetches an ARM rootfs from the Ubuntu core project. Currently, the [trusty] one.
- Uses qemu user emulation to chroot into the previously fetched ARM rootfs. Using a technique
    called ["chroot voodoo"].
- Inside the ARM chroot, we build cargo "natively" via emulation. Because we need cargo to build
    cargo we use these [unofficial binaries].

[trusty]: http://cdimage.ubuntu.com/ubuntu-core/releases/trusty/release/ubuntu-core-14.04.4-core-armhf.tar.gz
["chroot voodoo"]: https://gist.github.com/mikkeloscar/a85b08881c437795c1b9
[unofficial binaries]: https://github.com/warricksothr/RustBuild#nightly

## Usage

```
$ cd cargo-for-arm
$ docker build -t cargo-for-arm -f Dockerfile .
$ docker run --privileged cargo-for-arm
```

## Caveats

- QEMU user emulation is bad at handling multiple threads so the build process may "hang" when
    commands like `git clone`/`git submodule update` that use several threads are called. This
    makes this whole approach unreliable :-/.
- Emulation is very slow. Building cargo in debug mode takes 1h 12m on my laptop. For reference,
    building cargo on a quad core ARMv7 device takes ~6m.
- The unofficial cargo binary used here requires glibc >=2.19. This forces us to use the Ubuntu
    Trusty ARM rootfs, which has glibc-2.19, to build cargo. Therefore, the resulting cargo also
    depends on glibc >=2.19. Ideally, we'll like to make the glibc dependency as low as possible.
- The resulting cargo binary is dynamically linked to a bunch of C libraries related to SSL.
    Instead, we'll like cargo to be statically linked to SSL. This just hasn't been implemented.

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the
work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.
