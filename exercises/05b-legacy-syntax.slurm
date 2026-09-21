#!/bin/bash
#SBATCH --job-name=legacy-gpu
#SBATCH --output=legacy-%j.out
#SBATCH --error=legacy-%j.err
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1              # the OLD syntax -- silently becomes 12 GB
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:10:00

echo "I asked for --gres=gpu:1 (a whole GPU)."
echo "What I actually got:"
echo "  GPU_MEM_LIMIT_GB = ${GPU_MEM_LIMIT_GB:-<not set>}"
echo
echo "Confirm from outside the job with:"
echo "  scontrol show job $SLURM_JOB_ID | grep -i tres"
echo

sleep 120   # stay alive long enough to inspect from the login node
