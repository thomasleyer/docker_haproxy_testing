# docker_haproxy_testing
An example for testing docker images that die instantly in testing context

## Motivation

Invoking docker run on the haproxy image will, without further care, make the container die before tests have been
conducted:

```
#docker run -it haproxy:latest
[ALERT] 271/191340 (1) : Cannot open configuration file/directory /usr/local/etc/haproxy/haproxy.cfg : No such file or directory
```

## Idea

Spawn an instance with an alternative cmd (sleep 600) without the need to make special adjustments (e.g. defining a cmd
that would make the container sleep during testing based on environment variables).

Using ruby system()-calls in rspec's before and after steps.

## What it looks like

```
rspec spec/

image haproxy:latest
docker command: docker run --rm -d --name haproxy -v /tmp/docker_haproxy_testing/haproxy.conf:/usr/local/etc/haproxy/haproxy.cfg haproxy:latest sleep 600
container_id spawned: 320869b06f0c015bfdc7b2e82e4285229f2b3343f7a9712c8b1f8fc01c487c49
  Docker Build from id: "haproxy:latest"
    cmd
      should eq ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
  run image haproxy:latest
    File "/usr/local/etc/haproxy/haproxy.cfg"
      should exist
    File "/usr/local/sbin/haproxy"
      should exist
      should be file
      should be executable
      should be owned by "root"

Finished in 7.37 seconds (files took 0.43488 seconds to load)
6 examples, 0 failures
#
```