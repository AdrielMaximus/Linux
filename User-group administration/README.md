# Tutorial: Configuring Users, Groups, and Permissions in Linux

This tutorial explains how to set up a permission system in Linux for a small company with a CEO, three developers, and two clients. The project organizes users into groups (`dev`, `owner`, `client`) and defines permissions for three folders (`develop`, `finance`, `final_product`). Tested on WSL (Windows Subsystem for Linux).

## Objective
Simulate a company with:
- **Group `dev`**: Three developers (`jacobdev`, `josephdev`, `davidev`) with full access to `develop` and `final_product` folders.
- **Group `owner`**: One CEO (`CEO`) with full access to all folders.
- **Group `client`**: Two clients (`Sam_tsung`, `AmaDom`) with read/execute access to `final_product` only.
- **Folders**:
  - `develop`: Full access for `owner` and `dev`.
  - `finance`: Full access for `owner` only.
  - `final_product`: Full access for `owner` and `dev`; read/execute for `client`.

## Prerequisites
- Root access (use `sudo` in WSL).
- Filesystem with ACL (Access Control List) support. Verify with:
  ```bash
  mount | grep ext4
  ```
  Look for `acl` in the mount options.
- Install the `acl` package in WSL:
  ```bash
  sudo apt update && sudo apt install acl
  ```

## Step-by-Step Instructions

### 1. Create the Groups
Create three groups using `groupadd`:
```bash
sudo groupadd dev
sudo groupadd client
sudo groupadd owner
```

**Explanation**: The groups (`dev`, `client`, `owner`) organize users and define specific permissions.

### 2. Create Users and Assign to Groups
Create users with home directories (`-m`) and assign them to their primary groups using `-G`:
```bash
sudo useradd -m -G dev jacobdev
sudo useradd -m -G dev josephdev
sudo useradd -m -G dev davidev
sudo useradd -m -G client Sam_tsung
sudo useradd -m -G client AmaDom
sudo useradd -m -G owner CEO
```

Add the `CEO` user to the `dev` group for shared access to `develop` and `final_product`:
```bash
sudo usermod -aG dev CEO
```

Set passwords for users (optional, recommended for testing):
```bash
sudo passwd jacobdev
sudo passwd josephdev
sudo passwd davidev
sudo passwd Sam_tsung
sudo passwd AmaDom
sudo passwd CEO
```

**Explanation**: 
- `useradd -m -G <group> <user>` creates a user with a home directory and assigns them to the specified group.
- `usermod -aG dev CEO` adds `CEO` to the `dev` group without removing existing group memberships.
- Passwords allow testing user access with `su` or `sudo -u`.

### 3. Create the Folders
Create a project root directory and the three folders:
```bash
sudo mkdir -p /project
cd /project
sudo mkdir develop
sudo mkdir finance
sudo mkdir final_product
```

**Explanation**: The `/project` directory serves as the root for the project, containing the three folders with specific permissions.

### 4. Configure Folder Permissions
Use `chown` and `chmod` for standard permissions and `setfacl` for advanced permissions (ACLs) on `final_product`.

#### Folder `develop`: Full access for `owner` and `dev` (`rwxrwx---`)
```bash
sudo chown CEO:dev develop
sudo chmod 770 develop
```

**Explanation**:
- `chown CEO:dev develop`: Sets `CEO` as the owner and `dev` as the group.
- `chmod 770 develop`: Grants full access (`rwx`) to the owner (`CEO`) and group (`dev`), no access (`---`) to others.

#### Folder `finance`: Full access for `owner` only (`rwx------`)
```bash
sudo chown CEO:owner finance
sudo chmod 700 finance
```

**Explanation**:
- `chown CEO:owner finance`: Sets `CEO` as the owner and `owner` as the group.
- `chmod 700 finance`: Grants full access (`rwx`) to `CEO` only, no access for others.

#### Folder `final_product`: Full access for `dev` and `owner`, read/execute for `client`
```bash
sudo chown CEO:dev final_product
sudo chmod 770 final_product
sudo setfacl -m g:client:rx final_product
```

For recursive application (subfolders and files):
```bash
sudo setfacl -R -m g:client:rx final_product
```

**Explanation**:
- `chown CEO:dev final_product`: Sets `CEO` as the owner and `dev` as the group.
- `chmod 770 final_product`: Grants full access (`rwx`) to `CEO` and `dev`, no access to others.
- `setfacl -m g:client:rx final_product`: Uses ACLs to grant read/execute (`rx`) to the `client` group.
- `-R` applies ACLs to subfolders/files if needed.

### 5. Verify the Configuration
Check group memberships:
```bash
getent group dev
getent group client
getent group owner
```

Check folder permissions:
```bash
ls -ld /project/develop
ls -ld /project/finance
ls -ld /project/final_product
getfacl /project/final_product
```

**Expected `ls -ld` output**:
```
drwxrwx--- 2 CEO dev 4096 Oct 20 14:00 /project/develop
drwx------ 2 CEO owner 4096 Oct 20 14:00 /project/finance
drwxrwx---+ 2 CEO dev 4096 Oct 20 14:00 /project/final_product
```
- The `+` in `final_product` indicates ACLs are applied.

**Expected `getfacl` output for `final_product`**:
```
# file: project/final_product
# owner: CEO
# group: dev
user::rwx
group::rwx
group:client:r-x
mask::rwx
other::---
```

### 6. Test Permissions
Test access as different users:
- As `josephdev` (should have full access to `develop` and `final_product`):
  ```bash
  sudo -u josephdev touch /project/develop/test_dev
  sudo -u josephdev touch /project/final_product/test_dev
  sudo -u josephdev ls /project/finance  # Should fail
  ```
- As `Sam_tsung` (should have read/execute on `final_product` only):
  ```bash
  sudo -u Sam_tsung ls /project/final_product  # Should list
  sudo -u Sam_tsung touch /project/final_product/test_client  # Should fail
  sudo -u Sam_tsung ls /project/develop  # Should fail
  ```
- As `CEO` (should have full access to all folders):
  ```bash
  sudo -u CEO touch /project/develop/test_ceo
  sudo -u CEO touch /project/finance/test_ceo
  sudo -u CEO touch /project/final_product/test_ceo
  ```

**Explanation**: These tests confirm that permissions are correctly set. Use `sudo -u` in WSL to simulate user access, as `su` may not work seamlessly.

### Notes
- **WSL Considerations**:
  - Work in the Linux filesystem (e.g., `/project`), not `/mnt/c`, to avoid Windows permission conflicts.
  - If ACLs fail (`setfacl: Operation not supported`), verify ACL support with `mount | grep acl` or test with:
    ```bash
    touch /project/test_acl
    setfacl -m u:jacobdev:rwx /project/test_acl
    getfacl /project/test_acl
    ```
  - Update WSL if needed: `wsl --update`.
- **Common Issues**:
  - Ensure `acl` is installed.
  - Verify users are in the correct groups with `groups <username>`.
  - Use `sudo` for all commands requiring root access.

## Conclusion
This setup demonstrates Linux user/group management and permission control using standard permissions (`chown`, `chmod`) and ACLs (`setfacl`). It ensures secure access control for a company’s project folders.

Created on: October 20, 2025. Author: Adriel Maximus (with a little bit of grok to help my writing).
```