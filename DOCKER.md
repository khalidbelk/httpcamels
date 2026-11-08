# Docker

To run this unikernel with Docker, as I'm doing for deployment, for convenience, here is a small tutorial on how you can achieve this :

> Note: this is not the ultimate source or a general guide; but what I've been able to gather as knowledge from my unikernel deployments, including this one.

## Requirements

1. First, you need **Docker** and **opam** installed

```shell
docker -v # Verify docker
sudo apt install opam
opam init
```

Then install **aussi** via opam :

```shell
opam pin add aussi git+https://github.com/robur-coop/aussi.git
opam list aussi # Verify
```

2. Then declare `aussi` as a runtime for Docker in `/etc/docker/daemon.json` :

If you already have an existing configuration in that file, merge this entry by hand; if not, you can safely do:

```shell
sudo tee /etc/docker/daemon.json <<EOF
{
  "runtimes": {
    "solo5": { "path": "$(opam var bin)/aussi" }
  }
}
EOF
```
and apply changes with `sudo systemctl restart docker`

3. Make sure there's a [solo5.json](./solo5.json) manifest file next to the Dockerfile (if you clone, it will pick up the one from this repo).

And most importantly, in Linux, since we're targeting `hvt` we need access to `/dev/kvm` and `/dev/net/tun`.
You can also verify your current user is in the `kvm` group with

```shell
getent group kvm
```

## Build the image

```shell
docker build -t httpcamels .
```

## Run it

```shell
docker run -d --runtime=solo5 -p <HOST_PORT>:8080 httpcamels
```

Visit `http://localhost:<HOST_PORT>` and you should see the website !

**Credits**: To the [Solo5](https://github.com/Solo5/solo5/) developers and [Robur](https://robur.coop/), the *aussi* runtime developers, for creating and documenting big part of the process. ([link](https://github.com/robur-coop/aussi))
