# [dt](https://dt.plumbing) discord bot

That's what it is.

```
/dt [code <your code here>]
```

# Operator Notes

[Factor 0.99](https://re.factorcode.org/2023/08/factor-0-99-now-available.html) and Docker (or Podman) are required.

Run:

```shell
APPLICATION_ID=xxxxxx TOKEN=yyyyyy /where/ever/is/factor -roots=$PWD runbot.factor
```

Run, Val's cursed dev environment edition:

```shell
dotenv run flatpak run --env=DOCKER_CMD=podman org.factorcode.Factor -roots=$PWD runbot.factor
```

Invite to a guild:

in the "OAuth2 URL Generator" dev console section, select **only** the `bot` scope, no need for anything else.
Go to the generated URL, select a guild, confirm.

# Links

* https://discord.com/developers/docs/getting-started
* https://hub.docker.com/r/booniepepper/dt
* https://docs.factorcode.org/content/vocab-discord.html

# Etc

Commissioned by [J.R. Hill](https://so.dang.cool/), made by [Val Packett](https://val.packett.cool/).
