# svc

An interactive terminal tool for **Linux (systemd)** and **macOS (launchd)** that
shows what's running, how much memory it really uses, and what's listening on
ports — and lets you stop things safely.

```
┌───┬─────────────────────────┬────────────┬─────────────┬────────────────────────────────────┐
│ # │ SERVICE                 │ WITH CACHE │ REAL MEMORY │ DESCRIPTION                        │
├───┼─────────────────────────┼────────────┼─────────────┼────────────────────────────────────┤
│ 1 │ mysql.service           │    598.0MB │     412.3MB │ MySQL Community Server             │
│ 2 │ nginx.service           │     55.8MB │      18.1MB │ A high performance web server      │
├───┼─────────────────────────┼────────────┼─────────────┼────────────────────────────────────┤
│   │ Total                   │    653.8MB │     430.4MB │                                    │
└───┴─────────────────────────┴────────────┴─────────────┴────────────────────────────────────┘
```

## Features

- **Running services** (system or `--user`) in a table, sorted by memory.
- **Real memory**: shows memory a service actually holds, next to systemd's
  figure that includes reclaimable file cache.
- **Listening ports** (`-p`): protocol, port, address, PID, process, memory and
  the owning systemd unit.
- **Stop / disable services** or **kill processes by port** (`:8080`), with
  confirmation. Accepts numbers, lists (`1,4,7`), ranges (`2-5`) or names.
- **Dependency warnings** before stopping anything:
  - units systemd will stop along with it (`Requires=` / `BindsTo=`),
  - processes connected to it right now over TCP or Unix sockets
    (e.g. app workers connected to your database),
  - socket activation that would just start it again.
- **Critical services** (dbus, NetworkManager, wpa_supplicant, display manager,
  ssh, systemd-*, …) are flagged and need an extra `yes` to stop.
- Offers to stop the owning **service** instead of killing a process systemd
  would restart.
- **zsh tab completion** for options, running service names and ports.

## macOS

The same script works on macOS (bash 3.2 compatible, no extra
tools needed — it uses `launchctl`, `lsof` and `ps`). The macOS backend has been
tested against simulated `launchctl`/`lsof` output, not yet on a real Mac — please
open an issue if something looks off.

| | Linux | macOS |
|---|---|---|
| Services | systemd units | launchd jobs (`launchctl list`) |
| Default view | system services | **your agents** (`--system` for daemons, uses sudo) |
| Memory | real memory (cgroup, minus file cache) + with-cache | RSS of the job and its child processes |
| Ports / connections | `ss` | `lsof` |
| Stop | `systemctl stop` | `launchctl bootout` |
| Disable | `systemctl disable` | `launchctl disable` (survives login/reboot) |
| Dependency warnings | systemd deps + TCP/Unix clients + socket activation | TCP clients |

Apple's own `com.apple.*` jobs are hidden unless you pass `--all`, and are
flagged as critical; many of them are protected by SIP and can't be stopped.
Homebrew services show up as `homebrew.mxcl.<name>`.

## Install

```bash
git clone https://github.com/shambhu384/svc.git ~/svc
~/svc/install.sh
```

This symlinks `svc` into `~/.local/bin` and the zsh completion into `~/.zfunc`.
For completion, make sure your `~/.zshrc` has, before `compinit`:

```zsh
fpath=("$HOME/.zfunc" $fpath)
autoload -Uz compinit && compinit
```

## Usage

```bash
svc                # Linux: system services | macOS: your launchd agents
svc --user         # your user services / launchd agents (no sudo)
svc --system       # system services / launchd daemons (uses sudo)
svc --all          # macOS: include Apple's com.apple.* jobs
svc -f nginx       # only show services matching "nginx"
svc -p             # listening-ports view
svc -p -f 8080     # ports view filtered to "8080"
svc -s name        # sort by name/port instead of memory
svc -h             # help
```

Inside the menu:

| Key            | Services view                  | Ports view                         |
|----------------|--------------------------------|------------------------------------|
| `3`, `1,4`, `2-5` | stop those services         | kill the processes on those lines  |
| `name`         | stop a service by name         | —                                  |
| `:<port>`      | —                              | kill whatever listens on that port |
| `s <n>`        | show `systemctl status`        | —                                  |
| `p` / `b`      | go to ports view               | back to services                   |
| `m`            | toggle sort (memory / name)    | toggle sort (memory / port)        |
| `r` / `q`      | refresh / quit                 | refresh / quit                     |

## Requirements

- **Linux:** systemd (cgroup v2), bash, `ss` (iproute2), `ps`, `awk`.
- **macOS:** nothing extra — works with the built-in bash 3.2, `launchctl`, `lsof`, `ps`, `awk`.

## Notes

- Connection checks only see connections open *at that moment*; a client that
  connects only occasionally may not be detected.
- In `--user` mode, processes owned by other users (e.g. root daemons) are shown
  without a PID (Linux) or not at all (macOS), since they can't be seen without sudo.
- On macOS, dependency warnings cover TCP connections only (not Unix sockets),
  and launchd has no equivalent of systemd's `Requires=`.
