#!/bin/bash

echo "Changing the URL to Clementine"
sed -i -- 's/raw\.githubusercontent\.com\/fellipec\/customshell\/main/clementine\.fellipec\.com\/cs/g' webinstall.sh

echo "Uploading new custom environment installer..."
rsync -av --del --exclude .git ./ fellipec@clementine.vpn:/var/www/html/cs/

echo "Reverting back to the Github URL
sed -i -- 's/clementine\.fellipec\.com\/cs/raw\.githubusercontent\.com\/fellipec\/customshell\/main/g' webinstall.sh