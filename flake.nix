{
  description = "Vibetron - Ephemeral QEMU/KVM VM for AI coding agents";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      runtimeDeps = with pkgs; [
        qemu        # qemu-system-x86_64, qemu-img
        virtiofsd
        cdrkit      # genisoimage
        curl
        openssh     # ssh, ssh-keygen
        iproute2    # ss
        coreutils   # shuf, seq, mktemp
        diffutils   # cmp
        gnugrep
      ];
      vibetron = pkgs.stdenv.mkDerivation {
        pname = "vibetron";
        version = "0-unstable";
        src = ./.;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        dontBuild = true;
        installPhase = ''
          install -Dm755 vibetron $out/bin/vibetron
          wrapProgram $out/bin/vibetron \
            --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
        '';
        meta = {
          description = "Ephemeral QEMU/KVM VM for AI coding agents";
          homepage = "https://github.com/angelakis/vibetron";
          platforms = [ "x86_64-linux" ];
          mainProgram = "vibetron";
        };
      };
    in
    {
      packages.${system} = {
        default = vibetron;
        vibetron = vibetron;
      };
      apps.${system}.default = {
        type = "app";
        program = "${vibetron}/bin/vibetron";
        meta.description = vibetron.meta.description;
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = [ vibetron ];
      };
      nixosModules.default = { pkgs, ... }: {
        environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      };
    };
}
