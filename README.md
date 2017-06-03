Bits for setting up Minio/Camlistore on an XU4(Q) using Docker containers.

### Disable the GUI

    sudo systemctl set-default multi-user.target

### Change the default odroid password

    passwd odroid

### Add odroid to sudo nopasswd (optional, makes it feel like the Pi)

    echo "odroid ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/010_odroid-nopasswd

### Installing docker

    sudo apt-get install docker.io -y
    # Log in/out after running this to make the permissions effective
    sudo usermod -aG docker odroid

### Lets Encrypt via Lego:
        
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    # Fill out everything with a REPLACE_ME                     #
    # Change the challenge method if using different stuff      #
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    
    docker run --rm \
    -v $HOME/.config/lego:/.lego \
    -e CLOUDFLARE_EMAIL="REPLACE_ME@example.com" \
    -e CLOUDFLARE_API_KEY="REPLACE_ME" \
    keyglitch/lego-arm \
    --email="REPLACE_ME@example.com" \
    --domains="REPLACE_ME.example.com" \
    --dns="cloudflare" \
    --dns-resolvers="8.8.8.8" \
    --dns-resolvers="8.8.4.4" \
    -a \
    run \
    
### Handling Lets Encrypt certificate renewals

    # Basically all of the above, but with renew and --days 60 added.

    echo -e '#!/bin/bash\ndocker run --rm \
    -v $HOME/.config/lego:/.lego \
    -e CLOUDFLARE_EMAIL="REPLACE_ME@example.com" \
    -e CLOUDFLARE_API_KEY="REPLACE_ME" \
    keyglitch/lego-arm \
    --email="REPLACE_ME@example.com" \
    --domains="REPLACE_ME.example.com" \
    --dns="cloudflare" \
    --dns-resolvers="8.8.8.8" \
    --dns-resolvers="8.8.4.4" \
    -a \
    renew \
    --days=60
    ' | sudo tee /usr/local/bin/lego-renewal.sh
    chmod +x /usr/local/bin/lego-renewal.sh
    echo '@weekly odroid /usr/local/bin/lego-renewal.sh' | sudo tee /etc/cron.d/lego-ssl


### Minio Object Storage

Minio doesn't offer an ARM docker container (they do offer a prebuilt binary), but for the purposes of this article one was built. Check out the [Minio armhf Dockerfile](https://raw.githubusercontent.com/minio/minio/master/Dockerfile.armhf) to build your own with the latest changes.
    
    # Adding mount points for an external disk (1TB 2.5")
    # TIP: UUID will be unique to your drive/disk. To get /dev/sda1's UUID, run the following:
    # sudo blkid /dev/sda1
  
    # Adding disk to mount on boot
    echo 'UUID="5073-518C" /media/disk vfat rw,relatime,errors=remount-ro,uid=1000,gid=1000 0 0' | sudo tee -a /etc/fstab
    sudo mount -a
    sudo mkdir -p /media/disk/minio-storage
    
    # Starting Minio
    #
    # Minio will be started every time the Docker daemon is (so this container will come up on boot)
    # Make sure $HOME is populated with certificate information before proceeding if SSL is desired.
    
    ls $HOME/.config/lego/certificates/$HOSTNAME.*
    
    docker run -d -p 0.0.0.0:9000:9000 \
    --name minio-instance \
    -v /media/disk/minio-storage:/export \
    -v $HOME/.config/minio/:/root/.minio/ \
    -v $HOME/.config/lego/certificates/$HOSTNAME.key:/root/.minio/certs/private.key \
    -v $HOME/.config/lego/certificates/$HOSTNAME.crt:/root/.minio/certs/public.crt \
    --restart unless-stopped \
    keyglitch/minio-arm server /export


### Installing Camlistore

Note: Camlistore can fail to build inside this container (some of the asm bits are fickle)

    # Building the container -- skip this if you want to download a pre-built version
    mkdir camlistore && cd camlistore
    curl https://raw.githubusercontent.com/davidk/arm-storage/master/Dockerfiles/camlistore/Dockerfile > Dockerfile
    docker build -t camlistore .
   
    # Running camlistore, on port 3179 (this pulls a pre-built version from Docker hub) 
    docker run -d -p 0.0.0.0:3179:3179 \
        --name camlistore \
        -v $HOME/.config/lego/certificates/$HOSTNAME.key:/root/.config/camlistore/certs/private.key \
        -v $HOME/.config/lego/certificates/$HOSTNAME.crt:/root/.config/camlistore/certs/public.crt \
        -v $HOME/.config/camlistore:/root/.config/camlistore/ \
        -v /media/disk/camlistore_files:/root/var/camlistore \
        --restart unless-stopped \
        keyglitch/camlistore-arm

Permanently spinny disks are annoying. Make all /dev/sd stuff spin down through udev (h/t: https://wiki.archlinux.org/index.php/hdparm#Persistent_configuration_using_udev_rule)

    echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="/usr/bin/hdparm -B 127 -S 12 /dev/%k"' | sudo tee -a /etc/udev/rules.d/50-hdparm.rules

Jumbo frames (for networks which support GigE) -- this works around stock dhcp cfg overriding MTU too:

    echo -e '\nauto eth0\niface eth0 inet dhcp\n\tpost-up /sbin/ifconfig eth0 mtu 9000' | sudo tee -a /etc/network/interfaces


