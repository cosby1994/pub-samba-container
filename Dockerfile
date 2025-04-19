FROM alpine:3.10

# Create samba user and group
RUN addgroup -S samba && adduser -S -G samba samba

# Create shared directory with proper ownership and permissions
RUN mkdir -p /samba/share && \
    chown -R samba:samba /samba/share && \
    chmod -R 0775 /samba/share

# Install Samba
RUN apk update && apk add samba

# Configure Samba
RUN printf "%s\n" \
  "[global]" \
  " security = user" \
  " map to guest = Bad User" \
  " guest account = guest" \
  " min protocol = SMB2" \
  "" \
  "[share]" \
  " path = /samba/share" \
  " writable = yes" \
  " guest ok = yes" \
  " guest only = yes" \
  " create mode = 0664" \
  " directory mode = 0775" \
  > /etc/samba/smb.conf

# Expose ports
EXPOSE 139 445

# Healthcheck: check if smbd is responding
HEALTHCHECK CMD smbstatus || exit 1

# Start Samba
CMD ["/bin/ash", "-c", "nmbd -D && smbd -FS --no-process-group </dev/null"]
