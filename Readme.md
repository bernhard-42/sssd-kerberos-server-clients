# SSSD Configuration including Kerberos

## 1 Using Vagrant

Define the domain and the machines to be used by editing `config-machines.yaml`. Each host definition has the format

```yaml
- name:     "authx"
  ip:       "192.168.56.10"
  memory:   1024
  cpus:     1
  tag:      "server"
  image:    "bento/ubuntu-16.04"
```

and can then be started with vagrant by its `name` attribute, e.g.:

```bash
vagrant up authx
```

For this section, if you use the folder holding `config.sh` and all script folders then they are shared between all machines via the folder `/vagrant` in each guest (which is automatically shared by Vagrant between guest and host for the provider Virtualbox).

Edit `config.sh` and adapt at least `LDAP_ORG` , `USE_KRB5`.

- **Create Authentication Server**

    ```bash
    vagrant up authx
    ```

- **Create Centos 7.3 client**

    ```bash
    vagrant up c73
    ```

- **Create Ubuntu 16.04 client**

    ```bash
    vagrant up u1604
    ```

## 2 On existing machines

- **Create Authentication Server**

    Clone the project to an Ubuntu 16.04 (!) machine and edit 

    - `config-standalone.sh` and adapt domain and server address
    - `config.sh` to at least adapt `LDAP_ORG` , `USE_KRB5`

    Then execute

    ```bash
    sudo create-server.sh
    ```

- **Create Ubuntu 16.04 or Centos 7.3 client**

    Clone the project to the Ubuntu 16.04 or Centos 7.3 machine and copy `config-standalone.sh`, `config.sh` and `/etc/ssl/certs/cacert.pem` from the server to the installer directory on the client.

    Then execute

    ```bash
    sudo create-client.sh
    ```

## 3 Using docker

- **Create docker image**

    Clone the project to machine running docker and edit 

    - `config-standalone.sh` and adapt domain and server address
    - `config.sh` to at least adapt `LDAP_ORG` , `USE_KRB5`

    Then execute

    ```bash
    IMAGE_VERSION=1.0.1
    ./docker-build.sh $IMAGE_VERSION
    ```

    Results in ./target:

    ```bash
    client-installer.tgz
    server.tgz
    ```

- **Start docker container on (server)**

    Copy all files from `target` to the machine where the LDAP-KDC container should run and call

    ```bash
    tar -zxvf server.tgz
    docker load ldap-*.docker
    ./run.sh
    ```

- **Install and configure Clients**

    Copy all files from `target` to the machine that is a client of the LDAP-KDC and call

    ```bash
    tar -zxf client-installer.tgz
    ./client.sh
    ```

## 4 Test

- **Test LDAP**

    Check Authentication against LDAP only

    ```bash
    ldapwhoami -x -H ldap://authx.$DOMAIN -D "uid=alice,ou=People,$BASE" -w $PASSWORD
    ```

- **Test SSSD**

    Log into client machine and check sssd

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

## 5 LDAP Admin UI

If `USE_PHPLDAPADMIN` is `1` then `phpldapadmin` is configured at the port provided in `config.sh`.

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
