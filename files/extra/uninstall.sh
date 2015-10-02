#!/bin/sh

sh '/Library/Application Support/org.pqrs/Seil/uninstall_core.sh'

# remove receipts
rm -f /var/db/receipts/org.pqrs.driver.PCKeyboardHack.*
rm -f /var/db/receipts/org.pqrs.driver.Seil.*

exit 0
