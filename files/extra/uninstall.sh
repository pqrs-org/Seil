#!/bin/sh

/Applications/PCKeyboardHack.app/Contents/Library/extra/uninstall_core.sh

# remove receipts
rm -f /var/db/receipts/org.pqrs.driver.PCKeyboardHack.*

# kill processes
/usr/bin/killall PCKeyboardHack 2>/dev/null

exit 0
