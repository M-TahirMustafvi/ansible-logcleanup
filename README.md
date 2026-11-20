# ansible-logcleanup

An Ansible project that keeps log directories from filling up. It installs a
small cleanup script on each host and schedules it with cron, so files older
than a set number of days are deleted automatically and every run is recorded
in syslog.

Built as a learning project against a local Vagrant lab of three VMs.

## What it does

Cleanup jobs are described as data. Each job names a directory, a filename
pattern and how many days to keep files. On every host, the `logcleanup` role:

1. Creates each job's directory if it is missing.
2. Deploys one generic script, `/usr/local/bin/logcleanup.sh DIR PATTERN DAYS`,
   which deletes matching files older than DAYS and logs how many it removed.
   It refuses to run on `/`, on a missing directory or with a bad DAYS value.
3. Adds one cron entry per job in `/etc/cron.d/logcleanup`.
4. Writes an audit line to syslog whenever the script is deployed or changed.

Default jobs per group:

| Job | Directory | Pattern | Keep | Runs | Hosts |
|---|---|---|---|---|---|
| myapp | /var/log/myapp | *.log | 7 days | 02:30 | all |
| nginx | /var/log/nginx | *.gz | 14 days | 04:30 | web |
| pgdump | /var/backups/pg | *.sql.gz | 3 days | 03:15 | db |

## Project layout

```
.
├── ansible.cfg              # inventory path, remote user, Python interpreter
├── site.yml                 # playbook: applies the logcleanup role to all hosts
├── inventory/
│   ├── hosts.yml            # web1, web2 (group: web) and db1 (group: db)
│   └── group_vars/
│       ├── web.yml          # myapp + nginx jobs
│       └── db.yml           # myapp + pgdump jobs
└── roles/
    └── logcleanup/
        ├── defaults/main.yml    # default job list
        ├── files/logcleanup.sh  # generic cleanup script
        ├── tasks/main.yml       # directory, script and cron tasks
        ├── handlers/main.yml    # syslog audit handler
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
| `cron` | Only the cron schedules |

```bash
ansible-playbook site.yml --tags cron
```

### Adding or changing jobs

Edit the `logcleanup_jobs` list in `inventory/group_vars/<group>.yml`:

```yaml
logcleanup_jobs:
  - name: myapp
    dir: /var/log/myapp
    pattern: "*.log"
    retention_days: 7
  - name: nginx
    dir: /var/log/nginx
    pattern: "*.gz"
    retention_days: 14
    hour: "4"          # optional, default "2"
    minute: "30"       # optional, default "30"
```

A group's list replaces the default list from the role, so repeat any job
that group should keep. All keys are described in the
[role README](roles/logcleanup/README.md).

## Verifying on a host

```bash
cat /etc/cron.d/logcleanup             # the scheduled job
sudo /usr/local/bin/logcleanup.sh /var/log/myapp '*.log' 7   # run one job now
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
