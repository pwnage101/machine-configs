Running playbooks the first time
--------------------------------

Steps to run before any playbook:

* apt-get update && apt-get --yes upgrade
* apt-get install vim git ansible
* git clone https://github.com/pwnage101/machine-configs.git

Additional steps to run before server playbooks only:

* run the playbook once and it will error out early on
* `passwd sankey` on the host
* ssh-copy-id to the remote host

How to run a playbook:

    ssh to host, login as root
    cd path/to/machine-configs/ansible
    ansible-playbook -i inventory.ini <playbook>
