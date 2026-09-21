#!/bin/bash
#SBATCH --job-name=oom-demo
#SBATCH --output=oom-%j.out
#SBATCH --error=oom-%j.err
#SBATCH --partition=gpu
#SBATCH --gres=gpu_mem:4          # we ask for 4 GB...
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:10:00

echo "Requested: ${GPU_MEM_LIMIT_GB:-?} GB of VRAM"
echo "About to try to allocate 10 GB. This should not end well."
echo

# ...and then try to use 10. The watchdog will cancel this job.
# Fix: change gpu_mem:4 above to gpu_mem:12 and resubmit.
uv run --with torch python hog_vram.py 10
