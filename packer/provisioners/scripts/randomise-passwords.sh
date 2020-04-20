#!/bin/bash

USERS="root admin"
NUM_CHARS=12
PW_FILE=/etc/ann-vm-passwords

echo "=== ANN platform passwords ===" > "$PW_FILE"
chmod 600 "$PW_FILE"

for user in $USERS ; do
    # read from random device deleting non-alphanumeric characters until we have NUM_CHARS
    password=$(< /dev/urandom \
        tr -dc [:alnum:] \
        | head -c$NUM_CHARS)

    echo "Setting $user password to $password"
    echo "$password" | passwd --stdin "$user"

    echo "$user: $password" >> "$PW_FILE"
done