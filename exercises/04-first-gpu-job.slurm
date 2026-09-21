#!/bin/bash
#SBATCH --job-name=first-gpu
#SBATCH --output=first-gpu-%j.out
#SBATCH --error=first-gpu-%j.err
#SBATCH --partition=gpu
#SBATCH --gres=gpu_mem:8          # 8 GB of VRAM -- memory, not devices
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:10:00

echo "=== Where am I? ==="
hostname
echo

echo "=== What did SLURM give me? ==="
echo "GPU_MEM_LIMIT_GB = ${GPU_MEM_LIMIT_GB:-<not set>}"
echo "PYTORCH_CUDA_ALLOC_CONF = ${PYTORCH_CUDA_ALLOC_CONF:-<not set>}"
echo

echo "=== What does the physical card look like? ==="
# Note: this shows the WHOLE GPU, including other people's processes.
# Your budget is GPU_MEM_LIMIT_GB above, not what you see here.
nvidia-smi
