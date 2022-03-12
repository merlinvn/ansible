#!/usr/bin/env bash
ansible-playbook new-remote.yml -i hosts -kK --ask-vault-pass
