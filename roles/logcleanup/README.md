# logcleanup

Deploys a shell script that deletes old log files and schedules it with cron.

## Role Variables

Defaults live in `defaults/main.yml`:

| Variable | Default | Description |
|---|---|---|
| `logcleanup_script_path` | `/usr/local/bin/logcleanup.sh` | Where the script is installed |
| `logcleanup_jobs` | one `myapp` job | List of cleanup jobs, one cron line each |

Each job in `logcleanup_jobs` takes:

| Key | Required | Default | Description |
|---|---|---|---|
| `name` | yes | | Unique job name, used in the cron entry name |
| `dir` | yes | | Directory to clean |
| `pattern` | yes | | Filename pattern, e.g. `*.log` |
| `retention_days` | yes | | Delete files older than this many days |
| `minute` | no | `30` | Cron minute |
| `hour` | no | `2` | Cron hour |

Setting `logcleanup_jobs` in group_vars replaces the default list; it is not merged.

## Example Playbook

```yaml
- name: Logcleanup Playbook
  hosts: all
  become: true
  roles:
    - role: logcleanup
      logcleanup_jobs:
        - name: myapp
          dir: /var/log/myapp
          pattern: "*.log"
          retention_days: 14
```

## License

MIT
