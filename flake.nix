{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
  let
    systems = [ "aarch64-darwin" "x86_64-linux" ];
    forAll  = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
    image    = "imthai/qbittorrent-filebot";
    workflow = "build-and-push.yml";
    mkApp = pkgs: script: {
      type    = "app";
      program = toString (pkgs.writeShellScript "app" script);
    };
    pkgsLinux = nixpkgs.legacyPackages.x86_64-linux;
  in {
    # devShell dispo partout — édition sur kamino, build sur jakku
    devShells = forAll (pkgs: {
      default = pkgs.mkShell { packages = [ pkgs.docker pkgs.gh ]; };
    });

    apps = {
      # test — x86_64 natif → à lancer depuis jakku
      x86_64-linux.test = mkApp pkgsLinux ''
        set -e
        docker build --platform linux/amd64 -t ${image}:test .
        docker push ${image}:test
        echo "✓ ${image}:test pushed"
      '';

      # ci — dispo partout (git push + déclenche GHA multi-arch)
      aarch64-darwin.ci = mkApp nixpkgs.legacyPackages.aarch64-darwin ''
        set -e
        git push
        gh workflow run ${workflow}
        echo "✓ Workflow déclenché"
      '';
      x86_64-linux.ci = mkApp pkgsLinux ''
        set -e
        git push
        gh workflow run ${workflow}
        echo "✓ Workflow déclenché"
      '';
    };
  };
}
