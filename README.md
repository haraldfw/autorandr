# autoxconfig

This project was built using [the go-template](https://bitbucket.org/tktip/go-template)

## Building

Run `make` or `make build` to compile your app.

Run `make clean` to clean up binaries.

## Running

This template includes a convenience goal called `run`.
Simply: `make run` and your binary will be built and run.

You can also pass args to the run-command with the `ARGS` variable:

In bash:
```bash
ARGS="-flag1 val1 -flag2 val2" make run
```

In fish:
```bash
env ARGS="-flag1 val1 -flag2 val2" make run
```

And remember that you can string all these goals together:
```bash
ARGS="-flag1 val1 -flag2 val2" make test build run
```

*Note:* The `ARGS`-variable only affects the `run`-goal.

## Versioning strategy
This setup uses your git Tag or just hash for versioning. If you have not committed the code you are building the `dirty` postfix will be added.

If nothing else is specified you will also get a `test`-postfix when building. This is to clearly differentiate between images built for local/QA/production environments. This can however be overwritten. As is done in the `bitbucket-pipelines.yml` file, you can simply specify `DEV=true` to get a `dev`-postfix, or `PROD=true` to get no postfix at all.

```bash
> PROD=true make build
...
> DEV=true make build
...
```

*Note:* This affects all goals that use the generated version-tag.

To see what version you would get, experiment with the `make version`-call:
```bash
> make version
2de3bc8-dirty-test

> DEV=true make version
2de3bc8-dirty-dev

> PROD=true make version
2de3bc8-dirty
```

**NB:** *with great power comes great responsibility*

## Code style checking

The `revive.toml`-file defines a set of rules. These rules are used to criticize your code and make you feel bad about yourself. So giddy up and call your therapist, because ignoring/disabling rules should only be done in situations where there are **actually no way of complying with the rules**. These situations are extremely rare, so if you think you've found one you are most likely giving up too easily or you are thinking that your time is more valuable than the next person, that has to read and/or refactor your code. Simply take it one step at a time and solve one problem at a time. After a few steps you will most likely see where you have gone wrong and end up writing beautiful code in no time.

Consulting your colleagues is a good idea as well. Most people love pointing out style-mistakes in other people's code.

Remember: *the linter is your friend*

### vscode
Press `ctrl + ,`, search for `lint`, click `Go configuration`. You have to change 2 values:

1. Under `Lint Tool` change the value to `revive`.
1. Open `Edit in settings.json`
    * Add a new value under `USER SETTINGS`:
    `"go.lintFlags": ["-exclude=vendor/...", "-config=${workspaceFolder}/revive.toml"]`

### GoLand
See [this](https://github.com/vmware/dispatch/wiki/Configure-GoLand-with-golint) post specifying how to use the file-watchers plugin to do automatic linting on every file save.

See also [this other person posting an issue on revive's github](https://github.com/mgechev/revive/issues/7).

Change:

1. `Program`: `revive`
2. `Arguments`: `-exclude=vendor/... -config=/revive.toml $FilePath$`

**NB: This is untested. Please update if you figure out if this works (or not)**

I suspect that the `-config=path` or use of `$FilePath$` will be wrong. If it complains about the last part (`$FilePath$`) replace `$FilePath$` in `Arguments` with `./...`

If that doesn't work try removing `$FilePath$` from `Arguments` all together.

### vim
See [this](https://github.com/mgechev/revive#text-editors)
