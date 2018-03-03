# SSSD Configuration including Kerberos

## Create Authentication Server

Edit `config.sh` and adapt at least `DOMAIN` , `IP_PREFIX` , `SERVER_SUFFIX` , `LDAP_ORG` , `USE_KRB5`.

```bash
vagrant up authx
```

## Create centos 7.3 client

Copy `config.sh` and `/etc/ssl/certs/cacert.pem` from server (`authx`) to the installer directory on the client,

```bash
vagrant up c73
```

## Test LDAP
Check Authentication against LDAP only

```bash
ldapwhoami -x -H ldap://authx.$DOMAIN -D "uid=alice,ou=People,$BASE" -w $PASSWORD
```


## Test SSSD

Log into Centos 7.3 machine (c73)

```bash
vagrant ssh c73
```

and check sssd

```bash
(vagrant)> id alice
uid=10001(alice) gid=10001(alice) Gruppen=10001(alice),10040(all users),10060(acme users),10020(staff)


(vagrant)> su -l bob

(bob)> klist
Ticket cache: FILE:/tmp/krb5cc_10003_aYp5PL
Default principal: mallory@ACME.LOCALDOMAIN

Valid starting       Expires              Service principal
01/27/2018 12:45:00  01/27/2018 22:45:00  krbtgt/ACME.LOCALDOMAIN@ACME.LOCALDOMAIN
    renew until 01/28/2018 12:45:00


(bob)> ls -l /home
```


# License

Copyright 2018 Bernhard Walter

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
