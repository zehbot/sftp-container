FROM alpine:3.19

# Install OpenSSH server
RUN apk add --no-cache \
    openssh-server \
    shadow \
    && ssh-keygen -A \
    && rm -rf /var/cache/apk/*

# Create SFTP directory
RUN mkdir -p /home/sftp /var/run/sshd

# Create entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Create user if not exists' >> /entrypoint.sh && \
    echo 'if ! id "${SFTP_USER}" >/dev/null 2>&1; then' >> /entrypoint.sh && \
    echo '    adduser -D -u "${SFTP_UID}" -g "${SFTP_USER}" -h "${SFTP_ROOT}" "${SFTP_USER}"' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Create .ssh directory and configure authorized_keys' >> /entrypoint.sh && \
    echo 'mkdir -p /home/${SFTP_USER}/.ssh' >> /entrypoint.sh && \
    echo 'chmod 700 /home/${SFTP_USER}/.ssh' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# If SSH_KEY is provided, write it to authorized_keys' >> /entrypoint.sh && \
    echo 'if [ -n "${SSH_KEY}" ]; then' >> /entrypoint.sh && \
    echo '    rm -rf /home/${SFTP_USER}/.ssh/authorized_keys' >> /entrypoint.sh && \
    echo '    echo "${SSH_KEY}" > /home/${SFTP_USER}/.ssh/authorized_keys' >> /entrypoint.sh && \
    echo '    chmod 600 /home/${SFTP_USER}/.ssh/authorized_keys' >> /entrypoint.sh && \
    echo '    chown -R ${SFTP_USER}:${SFTP_USER} /home/${SFTP_USER}/.ssh' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Set password (only if SFTP_PASS is provided)' >> /entrypoint.sh && \
    echo 'if [ -n "${SFTP_PASS}" ]; then' >> /entrypoint.sh && \
    echo '    echo "${SFTP_USER}:${SFTP_PASS}" | chpasswd' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Ensure proper permissions' >> /entrypoint.sh && \
    echo 'chmod 755 "${SFTP_ROOT}"' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Start SSH daemon' >> /entrypoint.sh && \
    echo 'exec /usr/sbin/sshd -D -e' >> /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Environment variables with defaults
ENV SFTP_USER=sftp
ENV SFTP_PASS=
ENV SFTP_UID=1000
ENV SFTP_GID=1000
ENV SFTP_ROOT=/home/sftp
ENV SSH_KEY=

# Copy SBOM files
COPY SBOM.md sbom-cyclonedx.json /

# Expose SSH port
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
