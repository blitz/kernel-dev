{
  description = "Kernel development environments";

  inputs = {
    systems.url = "github:nix-systems/default-linux";

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay, fenix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";

        # A set of scripts to simplify kernel development.
        kernelDevTools = pkgs.callPackage ./tools.nix { };

        linuxCommonDependencies = [
          kernelDevTools
        ] ++ (with pkgs; [
          gnumake
          perl
          bison
          flex
          gmp
          libmpc
          mpfr
          pahole
          nettools
          bc
          rsync
          openssl
          cpio
          elfutils
          zstd
          python3Minimal
          zlib
          kmod
          ubootTools

          # For make menuconfig
          ncurses

          # For make gtags
          global

          # For git send-email 🫠
          gitFull
        ]);

        linuxLlvmDependencies = [
          pkgs.llvmPackages.bintools
          pkgs.llvmPackages.llvm
          pkgs.llvmPackages.clang
        ];

        linuxGccDependencies = [
          pkgs.gcc
        ];

        rust-analyzer = fenix.packages."${system}".rust-analyzer;

        linuxRustDependencies = rustVersion:
          let
            rustc = rust-overlay.packages."${system}"."${rustVersion}".override {
              extensions = [
                "rust-src"
                "rustfmt"
                "clippy"
              ];
            };

            rustPlatform = pkgs.makeRustPlatform {
              cargo = rustc;
              rustc = rustc;
            };

            bindgenUnwrapped = pkgs.callPackage ./bindgen/0.65.1.nix {
              inherit rustPlatform;
            };

            bindgen = pkgs.rust-bindgen.override {
              rust-bindgen-unwrapped = bindgenUnwrapped;
            };
          in
          [
            rustc
            bindgen
            rust-analyzer
          ];
      in
      {
        devShells = {
          default = self.devShells."${system}".linux_6_8;

          # Linux 6.8
          linux_6_8 = pkgs.mkShell {
            packages =
              linuxLlvmDependencies
              ++ (linuxRustDependencies "rust_1_74_1")
              ++ linuxCommonDependencies;

            # To force LLVM build mode. This should create less problems
            # with Rust interop.
            LLVM = "1";

            # Disable all automatically applied hardening. The Linux
            # kernel will take care of itself.
            NIX_HARDENING_ENABLE = "";
          };

          linux_6_8_gcc = pkgs.mkShell {
            packages =
              linuxGccDependencies
              ++ linuxCommonDependencies;

            # Disable all automatically applied hardening. The Linux
            # kernel will take care of itself.
            NIX_HARDENING_ENABLE = "";
          };

          # Linux 6.9
          linux_6_9 = pkgs.mkShell {
            packages =
              linuxLlvmDependencies
              ++ (linuxRustDependencies "rust_1_76_0")
              ++ linuxCommonDependencies;

            # To force LLVM build mode. This should create less problems
            # with Rust interop.
            LLVM = "1";

            # Disable all automatically applied hardening. The Linux
            # kernel will take care of itself.
            NIX_HARDENING_ENABLE = "";
          };

          linux_6_9_gcc = self.devShells."${system}".linux_6_9_gcc;
        };
      });
}
