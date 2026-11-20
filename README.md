# ansible-logcleanup

An Ansible project that keeps log directories from filling up. It installs a
small cleanup script on each host and schedules it with cron, so files older
than a set number of days are deleted automatically and every run is recorded
in syslog.

Built as a learning project against a local Vagrant lab of three VMs.

## What it does

On every host in the inventory, the `logcleanup` role:

1. Creates the log directory if it is missing.
2. Deploys `/usr/local/bin/logcleanup.sh`, which deletes matching files older
   than the retention period and logs how many it removed.
3. Adds a cron entry in `/etc/cron.d/logcleanup` that runs the script nightly.
4. Writes an audit line to syslog whenever the script is deployed or changed.

## Project layout

```
.
├── ansible.cfg              # inventory path, remote user, Python interpreter
├── site.yml                 # playbook: applies the logcleanup role to all hosts
├── inventory/
│   └── hosts.yml            # web1, web2 (group: web) and db1 (group: db)
└── roles/
    └── logcleanup/
        ├── defaults/main.yml    # overridable settings
        ├── tasks/main.yml       # directory, script and cron tasks
        ├── handlers/main.yml    # syslog audit handler
        ├── templates/           # logcleanup.sh.j2
        ├── meta/main.yml        # role metadata
        └── README.md            # role variables and usage
```

## Requirements

- Ansible core 2.14 or newer on the control machine
- Target hosts running Linux with Python 3, `cron` and `logger`
- SSH access as the `vagrant` user with sudo rights (see `ansible.cfg`)

The inventory points at a Vagrant private network:

| Host | Group | Address |
|---|---|---|
| web1 | web | 192.168.56.11 |
| web2 | web | 192.168.56.12 |
| db1 | db | 192.168.56.21 |

Edit `inventory/hosts.yml` to use your own machines.

## Usage

Check that the hosts are reachable:

```bash
ansible all -m ansible.builtin.ping
```

Preview the changes without applying them, then apply:

```bash
ansible-playbook site.yml --check --diff
ansible-playbook site.yml
```

### Tags

Run only part of the role with tags:

| Tag | Runs |
|---|---|
| `logcleanup` | The whole role |
| `script` | Only the script deployment |
| `cron` | Only the cron schedule |

```bash
ansible-playbook site.yml --tags cron
```

### Changing the settings

All settings and their defaults are listed in the
[role README](roles/logcleanup/README.md). Override them in the playbook, in
`inventory/group_vars/`, or on the command line:

```bash
ansible-playbook site.yml -e logcleanup_dry_run=true
```

## Verifying on a host

```bash
cat /etc/cron.d/logcleanup             # the scheduled job
sudo /usr/local/bin/logcleanup.sh      # run a cleanup now
journalctl -t logcleanup               # cleanup runs and deployment audits
```

## Linting

```bash
pipx install ansible-lint
ansible-lint
```

## Branches

- `main`: single cleanup job configured with simple variables
- `lesson5`: several cleanup jobs defined as a list, set per host group

## License

MIT
