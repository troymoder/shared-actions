default:
    @just --list

fmt:
    dprint fmt
    shfmt -w .
    just --unstable --fmt
    nix fmt .
