#!/bin/bash
#SBATCH --account=PawseyXXXX
#SBATCH --partition=workq
#SBATCH --time=24:00:00
#SBATCH --nodes=4
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=12
#SBATCH --export=NONE

. /etc/bash.bashrc

module unload PrgEnv-cray
module unload cray-mpich2
module load PrgEnv-gnu
module load cray-mpich

module list

export OMP_NUM_THREADS=1

# Command line
srun -n 8 /path_to_MrBayes/bin/mb InputFile.mrbayes
