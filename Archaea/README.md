# Archaea 
is a set of windows Batch files that are used to reset and setup Dojo PCs to maintain PCs at a functional Level currently there are 5 scripts 
- awake: Creates a copy of itself + all local installers to the host machine under ~/Downloads/Archaea
- delete: Delete all non-critical files from the PC to save space
- setup: Installs all needed programs (updates them if already installed) and sets DNS to Dojos Adguard Home instance
- start: Is the runner, runs Delete and setup
- winget: Installs winget
- archaea_allinone: Is all previous scripts combined into one runnable script

### TODO
- [ ] create a script / system that will run from a network share
- [ ] add command line flags for certain settings + a default
