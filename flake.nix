{
    description = "ASUS Screenpad Module";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = nixpkgs.legacyPackages.${system};
            linux = pkgs.linuxPackages_latest.kernel;
        in {
            devShell = pkgs.mkShell {
                name = "asus-wmi-screenpad";
                packages = [ linux ];
                KERNEL_MODULES = "${linux.dev}/lib/modules/${linux.modDirVersion}";
                CPATH = builtins.concatStringsSep ":" [
                    "${linux.dev}/lib/modules/${linux.modDirVersion}/source/arch/x86/include/generated"
                    "${linux.dev}/lib/modules/${linux.modDirVersion}/source/include"
                    "${linux.dev}/lib/modules/${linux.modDirVersion}/build/include"
                    "${linux.dev}/lib/modules/${linux.modDirVersion}/build/arch/x86/include/generated"
                    "${linux.dev}/lib/modules/${linux.modDirVersion}/source/arch/x86/include/generated/uapi"
                    "${linux.dev}/lib/modules/${linux.modDirVersion}/source/include/generated/uapi"
                ];
            };

            defaultPackage = pkgs.lib.makeOverridable (kernel: pkgs.stdenv.mkDerivation {
                name = "asus-wmi-screenpad";
                version = "0.1.0";

                hardeningDisable = [ "pic" ];
                nativeBuildInputs = kernel.moduleBuildDependencies;

                makeFlags = [
                    "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
                ];

                src = ./.;

                installPhase = ''
                    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform
                    cp obj/* $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform
                '';
            }) linux;
        }
    );
}
