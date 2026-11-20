# logcleanup

Deploys a shell script that deletes old log files and schedules it with cron.

## Role Variables

Defaults live in `defaults/main.yml`:

| Variable | Default | Description |
|---|---|---|
| `logcleanup_log_dir` | `/var/log/myapp` | Directory to clean |
| `logcleanup_retention_days` | `7` | Delete files older than this many days |
| `logcleanup_file_suffix` | `*.log` | Filename pattern to match |
| `logcleanup_script_path` | `/usr/local/bin/logcleanup.sh` | Where the script is installed |
| `logcleanup_minute` | `30` | Cron minute |
| `logcleanup_hour` | `2` | Cron hour |
| `logcleanup_dry_run` | `false` | Only list matching files instead of deleting |

## Example Playbook

```yaml
- name: Logcleanup Playbook
  hosts: all
  become: true
  roles:
    - role: logcleanup
      logcleanup_retention_days: "14"
```

## License

MIT
