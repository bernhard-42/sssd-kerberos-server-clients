# SSSD Configuration including Kerberos

## 1 Using Vagrant

### 1.1 Create Authentication Server

Edit `config.sh` and adapt at least `DOMAIN` , `IP_PREFIX` , `SERVER_SUFFIX` , `LDAP_ORG` , `USE_KRB5`.

```bash
vagrant up authx
```

### 1.2 Create Centos 7.3 client

Copy `config.sh` and `/etc/ssl/certs/cacert.pem` from server (`authx`) to the installer directory on the client.

```bash
vagrant up c73
```

### 1.3 Create Ubuntu 16.04 client

Copy `config.sh` and `/etc/ssl/certs/cacert.pem` from server (`authx`) to the installer directory on the client.

```bash
vagrant up u1604
```

## 2 On existing machines

### 2.1 Create Authentication Server

Clone the project to the Ubuntu 16.04 (!) machine and edit `config.sh` and adapt at least `DOMAIN` , `IP_PREFIX` , `SERVER_SUFFIX` , `LDAP_ORG` , `USE_KRB5`.

```bash
sudo server.sh
```

### 2.2 Create Ubuntu 16.04 or Centos 7.3 client

Clone the project to the Ubuntu 16.04 or Centos 7.3 machine and copy `config.sh` and `/etc/ssl/certs/cacert.pem` from server (`authx`) to the installer directory on the client.

```bash
sudo client.sh
```

## 3 Using docker

### 3.1 Create docker image

Clone the project to the Ubuntu 16.04 (!) machine and edit `config.sh` and adapt at least `DOMAIN` , `IP_PREFIX` , `SERVER_SUFFIX` , `LDAP_ORG` , `USE_KRB5`.

```bash
IMAGE_VERSION=1.0.1
./docker-build.sh $IMAGE_VERSION
```

Results in ./target:

```bash
cacert.pem
client-installer.tgz
config.sh
ldap-kdc-poc.acme.local-1.0.1.docker
lib.sh
run.sh
```

### 3.2 Server

Copy all files in target to the machine where the LDAP-KDC container should run and call

```bash
./run.sh
```

### 3.3 Clients

Copy all files in target to the machine that is a client of the LDAP-KDC and call

```bash
tar -zxf client-installer.tgz
./client.sh
```

## 4 Test

### 4.1 Test LDAP

Check Authentication against LDAP only

```bash
ldapwhoami -x -H ldap://authx.$DOMAIN -D "uid=alice,ou=People,$BASE" -w $PASSWORD
```

### 4.2 Test SSSD

Log into Centos 7.3 machine (c73)

```bash
vagrant ssh c73
```

and check sssd

```bash
(vagrant)> id alice
uid=10001(alice) gid=10001(alice) Gruppen=10001(alice),10040(all users),10060(acme users),10020(staff)


(vagrant)> su -l bob
Password:
Creating directory '/home/bob'.

(bob)> id
uid=10002(bob) gid=10002(bob) groups=10002(bob),10020(staff),10040(all users),10060(acme_users)
```

If Kerberos is configured (`USE_KRB5=1` in `config.sh`) a ticket should be created:

```bash
(bob)> klist
Ticket cache: FILE:/tmp/krb5cc_10003_aYp5PL
Default principal: mallory@ACME.LOCALDOMAIN

Valid starting       Expires              Service principal
01/27/2018 12:45:00  01/27/2018 22:45:00  krbtgt/ACME.LOCALDOMAIN@ACME.LOCALDOMAIN
    renew until 01/28/2018 12:45:00
```

## 4 LDAP Admin UI

If `PHPLDAPADMIN` is `1` then `phpldapadmin` is configured at the port provided in `config.sh`.

Call e.g. <http://$SERVER_IP:8389/phpldapadmin/>

## License

Copyright 2018 Bernhard Walter

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
