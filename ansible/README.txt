Steps to run before any playbook:

* install git
* install ansible
* git clone https://github.com/pwnage101/machine-configs.git

Additional steps to run before server playbooks only:

* ssh-copy-id to the remote host

How to run a playbook:

    ssh to host, login as root
    cd path/to/machine-configs/ansible
    ansible-playbook -i inventory.ini <playbook>
