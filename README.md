# Linux Kernel Development Environment via Nix

Welcome to a streamlined Linux kernel development setup using Nix
flakes. This project simplifies the process of setting up a
development environment for the Linux kernel, ensuring that you have
all the necessary dependencies, including specific versions of Rust
and bindgen, preinstalled in a devShell.

## Quick Start

Getting started with your kernel development environment is incredibly
simple. If you're aiming to develop for Linux version 6.8, all you
need is a single command:

```shell
linux$ nix develop github:blitz/kernel-dev#linux_6_8
```

This will drop you into a shell with all the dependencies required for
working on the Linux 6.8 kernel preinstalled.

### Features

- **Simplicity**: Forget about the hassle of managing multiple
  dependencies and their versions. One command is all it takes.
- **Reproducibility**: With Nix flakes, your development environment
  is reproducible, ensuring that your setup is always consistent and
  predictable.
- **Version-specific environments**: Tailored development environments
  for specific Linux kernel versions, starting with Linux 6.8.
- **Rust and LLVM-enabled**: Ready for the future of kernel development!

### Requirements

- Nix package manager with flake support enabled.

## Usage

To start developing for a different version of the Linux kernel, use
the following pattern, replacing linux_6_8 with the target version
(note: versions are added based on community contributions and
demand):

```shell
$ nix develop github:blitz/kernel-dev#linux_<major_version>_<minor_version>
```

This will drop you in a shell with `clang` and `rustc` matching the
kernel version. If you need a `gcc`-based environment, use:

```shell
$ nix develop github:blitz/kernel-dev#linux_<major_version>_<minor_version>_gcc
```

If you don't find the exact version that you need, one that is close
_might_ work as well.

## Contributing

Contributions are welcome! Whether it's adding support for new kernel
versions, improving the setup process, or documentation - feel free to
fork the project and submit a pull request.

## License

This project is open source and available under the MIT License.
