#!/bin/bash

# Create the Docker group. Ignore it if the group already exists.
sudo groupadd docker

# Add the current user to the Docker group.
sudo usermod -aG docker $USER

# Restart the Docker daemon.
sudo systemctl restart docker

# Change Docker socket permissions.
sudo chmod 666 /var/run/docker.sock

# Apply the new group membership.
newgrp docker << EOF

# Check Docker version.
docker -v

# Check running containers.
docker ps

echo "Docker setup is complete. You can now use Docker without sudo."
echo "Warning: Docker socket permissions were changed to 666. This may not be recommended for security."
echo "Log out and log back in to apply this permanently system-wide."

# Keep the current shell open for the user.
$SHELL
EOF
