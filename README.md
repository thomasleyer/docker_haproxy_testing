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
#rspec spec/

image haproxy:latest
27e173e4183c3f25e38be88053aaa3c995e498cc67305efba31152fd555ac102
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
testhaproxy

Finished in 8.29 seconds (files took 0.43959 seconds to load)
6 examples, 0 failures

#
```