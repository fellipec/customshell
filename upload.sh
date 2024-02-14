#!/bin/bash

#Changes the URLs to work with Clementine server, uploads the files through the VPN
#and revert the URLs back to the Github defaults.

echo -e "\nChanging the URL to Clementine"
sed -i 's/raw\.githubusercontent\.com\/fellipec\/customshell\/main/clementine\.fellipec\.com\/cs/g' webinstall.sh

echo "Uploading new custom environment installer..."
rsync -av --del --exclude .git ./ fellipec@clementine.vpn:/var/www/html/cs/

echo -e "\nReverting back to the Github URL"
sed -i 's/clementine\.fellipec\.com\/cs/raw\.githubusercontent\.com\/fellipec\/customshell\/main/g' webinstall.sh