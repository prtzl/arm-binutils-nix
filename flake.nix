{
  description = "arm-none-eabi-gdb from ARM 15.2 source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          pkgs = import nixpkgs { inherit system; };

          gdbArm = pkgs.stdenv.mkDerivation {
            pname = "arm-none-eabi-gdb";
            version = "15.2-arm";

            src = pkgs.fetchurl {
              url = "https://developer.arm.com/-/media/Files/downloads/gnu/15.2.rel1/srcrel/arm-gnu-toolchain-src-snapshot-15.2.rel1.tar.xz";
              sha256 = "sha256-BvTleStWanccMArG9Gw0IuI+NPTjpdRKjLVZTq1vuC4=";
            };

            nativeBuildInputs = with pkgs; [
              autoconf
              automake
              bison
              file
              flex
              gawk
              gnumake
              help2man
              libtool
              makeWrapper
              perl
              pkg-config
              texinfo
              sourceHighlight
            ];

            buildInputs = with pkgs; [
              readline
              ncurses
              expat
              sourceHighlight
              zlib
              python3
              gmp
              mpfr
              libmpc
            ];

            sourceRoot = "binutils-gdb";
            configureScript = "binutils-gdb/configure";

            configureFlags = [ ];

            configurePhase = ''
              runHook preConfigure

              ./configure \
                --prefix=$out \
                --target=arm-none-eabi \
                --disable-werror \
                --disable-nls \
                --disable-doc \
                --without-guile \
                --enable-tui \
                --enable-source-highlight

              # ./configure \
              #   --target=arm-none-eabi \
              #   --host=x86_64-unknown-linux-gnu \
              #   --build=x86_64-unknown-linux-gnu \
              #   --with-python \
              #   --with-expat \
              #   --with-gmp \
              #   --with-mpfr \
              #   --with-system-readline \
              #   --enable-tui \
              #   --disable-werror \
              #   --with-curses \
              #   --disable-sim \
              #   --without-guile

              runHook postConfigure
            '';

            buildPhase = ''
              make -j$NIX_BUILD_CORES
            '';

            installPhase = ''
              make install
            '';
          };

        in
        {
          packages.default = gdbArm;

          devShells.default = pkgs.mkShell {
            packages = gdbArm.nativeBuildInputs;
          };
        };
    };
}
