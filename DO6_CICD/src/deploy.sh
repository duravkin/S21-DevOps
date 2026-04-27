#!/bin/bash

VM_IP="192.168.1.100"
USER="deploy_user"

scp src/SimpleBashUtils/cat/s21_cat src/SimpleBashUtils/grep/s21_grep $USER@$VM_IP:/usr/local/bin
