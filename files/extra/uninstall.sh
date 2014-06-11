#!/bin/sh

/Applications/Seil.app/Contents/Library/extra/uninstall_core.sh

# remove receipts
rm -f /var/db/receipts/org.pqrs.driver.PCKeyboardHack.*
rm -f /var/db/receipts/org.pqrs.driver.Seil.*

# kill processes
/usr/bin/killall Seil 2>/dev/null

exit 0
