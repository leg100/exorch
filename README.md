# ExOrch

Run SSH commands on cloud instances:

```bash
exorch tag:role=nginx tag:env=prod "service nginx restart"
```

Features:

* scalable: make 1000s of parallel SSH connections
* programmable: customise handling of args, filters, ssh params, and commands

## Longer term goals

I would like to turn this into something similar to Ansible, albeit scalable and programmable.

## Todo

- [x] instances: EC2
- [ ] instances: Google Cloud
- [ ] instances: Azure
- [ ] direct-tcpip channel for connecting via jumphosts (i.e. SSH ProxyForward)
- [ ] run ansible modules
- [ ] run commands in parallel on an instance
- [ ] specify dependencies between commands/instances

#### handlers

* filter_instances(args, state) -> [{filter_key, filter_value}]
* ssh_params(args, instance, state)
* run_cmd(args, instance, state) -> cmd_string
* format_output(args, instance, stdout, stderr, exit_code, state) -> map
