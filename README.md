# Vibetron

A single bash script that spins up an ephemeral QEMU/KVM virtual machine pre-loaded with [Claude Code](https://claude.ai) and [Codex](https://github.com/openai/codex) — a sandboxed environment for running AI coding agents safely.

Your current directory is mounted read-write into the VM at `/workspace`, so agents can edit your code without risking your host system.

Inspired by https://github.com/lynaghk/vibe and its earlier bash version.

## Requirements

- Linux with KVM support
- `qemu-system-x86_64`, `qemu-img`, `virtiofsd`, `genisoimage`, `curl`, `ssh`

On Debian/Ubuntu:

```bash
sudo apt install qemu-system-x86 qemu-utils virtiofsd genisoimage curl openssh-client iproute2
```

On Arch Linux:

```bash
sudo pacman -S qemu-full virtiofsd cdrtools curl openssh iproute2
```

On NixOS (or any system with Nix + flakes), a `flake.nix` is provided that
wraps the script with all of its runtime dependencies. You also need KVM
enabled on the host (`virtualisation.libvirtd.enable = true;` or at minimum
`boot.kernelModules = [ "kvm-intel" ];`/`"kvm-amd"`, plus your user in the
`kvm` group).

Run it directly without installing:

```bash
nix run github:angelakis/vibetron
# or from a local checkout:
nix run .
```

Install into your profile:

```bash
nix profile install github:angelakis/vibetron
vibetron
```

Or drop into a dev shell that has `vibetron` on `PATH`:

```bash
nix develop
```

## Usage

```bash
./vibetron              # 4G RAM, 4 CPUs, 10G disk
./vibetron --ram 8G --cpus 8
./vibetron --update-baked   # rebuild the provisioned image
```

On first run, Vibetron downloads a Debian 13 cloud image, bakes in dev tools (build-essential, node, ripgrep, Claude Code, Codex), and caches the result for fast subsequent boots.

## Inside the VM

Two convenience aliases are provided:

```
claude-yolo   # claude --dangerously-skip-permissions
codex-yolo    # codex --dangerously-bypass-approvals-and-sandbox
```

Host directories `~/.claude` and `~/.codex` are mounted in, so your API keys and config carry over automatically.

If your project has a `.git` directory, Vibetron bind-mounts `/tmp` over `/workspace/.git` inside the VM. This keeps agents from reading or writing your host Git metadata while still allowing normal file edits in `/workspace`.

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--ram SIZE` | `4G` | VM memory |
| `--cpus N` | `4` | CPU count |
| `--disk SIZE` | `10G` | Overlay disk size |
| `--ssh-port PORT` | auto | SSH port (auto-selected for concurrency) |
| `--base-image PATH` | — | Use a local Debian image |
| `--image-url URL` | Debian trixie daily genericcloud | Override image download URL |
| `--cache-dir PATH` | `~/.cache/vibetron` | Override cache directory |
| `--baked-image PATH` | `cache-dir/baked.qcow2` | Override baked image path |
| `--update-baked` | — | Force rebuild the baked image |
| `--no-bake` | — | Skip baking, use base image directly |
