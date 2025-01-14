#!/bin/sh

set -eux

# Install or update the guestagent binary
install -m 755 "${MACVZ_CIDATA_MNT}"/macvz-guestagent /usr/local/bin/macvz-guestagent

# Launch the guestagent service
if [ -f /sbin/openrc-init ]; then
	# Install the openrc macvz-guestagent service script
	cat >/etc/init.d/macvz-guestagent <<'EOF'
#!/sbin/openrc-run
supervisor=supervise-daemon

name="macvz-guestagent"
description="Forward ports to the macvz-hostagent"

command=/usr/local/bin/macvz-guestagent
command_args="daemon"
command_background=true
pidfile="/run/macvz-guestagent.pid"
EOF
	chmod 755 /etc/init.d/macvz-guestagent

	rc-update add macvz-guestagent default
	rc-service macvz-guestagent start
else
	# Remove legacy systemd service
	rm -f "/home/${MACVZ_CIDATA_USER}.linux/.config/systemd/user/macvz-guestagent.service"

	sudo /usr/local/bin/macvz-guestagent install-systemd
fi
