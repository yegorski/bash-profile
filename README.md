# Mac .bash_profile

`.bash_profile` with some useful commands for developing on a Mac.

## Usage

Backup existing file and copy the bash profile.

```bash
# backup
mv ~/.bash_profile ~/.bash_profile.bak

# copy
git clone git@github.com:yegorski/bash-profile.git
cp bash-profile/.bash_profile ~/.bash_profile
chmod 0644 ~/.bash_profile

# source it or open a new terminal window
. ~/.bash_profile
```
