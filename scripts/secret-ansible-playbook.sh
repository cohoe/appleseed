#!/usr/bin/env zsh

# Run the mac-secret playbook with vault password from 1Password
ANSIBLE_VAULT_PASSWORD_FILE=scripts/ansible-vault-pass ansible-playbook "$@"
