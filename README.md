smartstack-demo
===============

SmartStack Demo for Vagrant and Chef

Requires Vagrant 1.5 +

How to use
* Locally clone repo
* run ```vagrant up```
* wait a bit.

This will init two VMs on 192.168.33.11 and .12
You can check what they are doing with

```serf members```

http://192.168.33.11:3212/

```tail -f /etc/service/nerve/log/main/current```

and stopping / starting the mysql or the memcache service

```service mysql stop``` or ```service memcache start``` etc

Followed by a new

```serf members``` and ```cat /etc/haproxy/haproxy.cfg``` etc
