#!/bin/bash
ansible localhost -m ansible.builtin.debug -a var="$2" -e "@$1"
