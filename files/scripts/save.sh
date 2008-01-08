#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

tmpfile=`mktemp /tmp/PCKeyboardHack.XXXXXX` || exit 1
basedir="/Applications/PCKeyboardHack"
outfile="$basedir/scripts/sysctl.sh"

cat > "$tmpfile" <<EOF
#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

i=0
while [ -z "\`sysctl -n pckeyboardhack.version\`" ]; do
  echo "Waiting PCKeyboardHack kext setup ...(\$i)"
  sleep 3
  i=\`expr \$i + 1\`
  if [ \$i -gt 9 ]; then
    echo "Giveup waiting"
    exit 1
  fi
done

EOF

for key in `sysctl pckeyboardhack 2>&1 | grep -oE '^pckeyboardhack.(enable|keycode)_[^:]+'`; do
    value=`sysctl -n $key`
    if [ "$value" != "0" ]; then
        echo "sysctl -w $key=$value" >> "$tmpfile"
    fi
done

chmod 755 "$tmpfile"
mv "$tmpfile" "$outfile"

exit 0
