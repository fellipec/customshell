#!/bin/bash

echo "Uploading new custom environment installer..."
rsync -av --del --exclude .git ./ fellipec@clementine.vpn:/var/www/html/cs/