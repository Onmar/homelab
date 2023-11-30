<!-- Preview: Ctrl + K -> V -->
# Titan Setup

# Install Debian on ZFS Root
[https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/Debian%20Bookworm%20Root%20on%20ZFS.html]()

User: ansible<br>
Password: &lt;any&gt;

# Comissioning

* Create install snapshots
  ```
  sudo zfs snapshot -r bpool@install
  sudo zfs snapshot -r rpool@install
  ```

* Run Disk Setup

* Add writecache modules to kernel
  ```
  echo "dm_writecache" >> /etc/initramfs-tools/modules
  echo "dm_mod" >> /etc/initramfs-tools/modules  # Might not be necessary
  update-initramfs -u -k all
  ```

* Run ansible with custom ip
  ```
  ansible-playbook production.yml --extra-vars "ansible_host=192.168.1.xxx" --ask-pass --ask-become-pass"
  ```
