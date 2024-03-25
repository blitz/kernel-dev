{
  description = "Kernel development environments";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

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

  outputs = { self, nixpkgs, rust-overlay, fenix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";

        linuxCommonDependencies = with pkgs; [
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

          llvmPackages.bintools
          llvmPackages.clang
          llvmPackages.llvm

          # For make menuconfig
          ncurses
        ];

        rust-analyzer = fenix.packages."${system}".rust-analyzer;

        rustc_1_76 = rust-overlay.packages."${system}".rust_1_76_0.override {
          extensions = [
            "rust-src"
            "rustfmt"
            "clippy"
          ];
        };

        rust-bindgen_0_65_1 = let
          rustPlatform_1_76 = pkgs.makeRustPlatform {
            cargo = rustc_1_76;
            rustc = rustc_1_76;
          };

          rust-bindgen-unwrapped_0_65_1 = pkgs.callPackage ./bindgen/0.65.1.nix {
            rustPlatform = rustPlatform_1_76;
          };
        in
          pkgs.rust-bindgen.override {
            rust-bindgen-unwrapped = rust-bindgen-unwrapped_0_65_1;
          };
      in
      {
        devShells.default = self.devShells."${system}".linux_6_8;

        devShells.linux_6_8 = pkgs.mkShell {
          packages = [
            rustc_1_76
            rust-bindgen_0_65_1
            rust-analyzer
          ] ++ linuxCommonDependencies;

          # To force LLVM build mode. This should create less problems
          # with Rust interop.
          LLVM = "1";

          # Disable all automatically applied hardening. The Linux
          # kernel will take care of itself.
          NIX_HARDENING_ENABLE = "";
        };
      }
    );
}
