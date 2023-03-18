# Building PISM on HPC systems

[![License: GPL-3.0](https://img.shields.io:/github/license/pism/pism-builds)](https://opensource.org/licenses/GPL-3.0)
[![DOI](https://zenodo.org/badge/42963946.svg)](https://zenodo.org/badge/latestdoi/42963946)


This repository contains scripts that help with building the Parallel Ice Sheet Model (PISM) and its
prerequisites (such as PETSc) on some HPC systems.

To use one of these environment setups, run

    cd ~
    git clone https://github.com/pism/pism-builds.git

and then add

    source ~/pism-builds/pleiades/profile
    source ~/pism-builds/common_settings

to your `.bash_profile` or `.bashrc` on `pleiades` (replace `pleiades`
with the name of the system you use).

