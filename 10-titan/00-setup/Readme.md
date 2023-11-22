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

* Run ansible with custom ip
  ```
  ansible-playbook production.yml --extra-vars "ansible_host=192.168.1.xxx" --ask-pass --ask-become-pass"
  ```
