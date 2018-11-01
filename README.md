# Building PISM on Debian some HPC systems

This repository contains scripts that help with building PISM and its
prerequisites (such as PETSc) on some HPC systems.

To use one of these environment setups, run

    cd ~
    git clone https://github.com/pism/hpc-builds.git

and then add

    source ~/pism-builds/pleiades/profile
    source ~/pism-builds/common_settings

to your `.bash_profile` or `.bashrc` on `pacman` (replace `pleiades`
with the name of the system you use).

