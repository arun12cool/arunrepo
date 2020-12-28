#!/bin/bash

rsync -avz --no-perms --no-owner --no-group --rsync-path='/usr/bin/sudo /usr/bin/rsync'  rsync@keygen-server.freshpo.com:/home/ /home/ --update --existing
