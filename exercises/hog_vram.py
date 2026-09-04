"""Allocate GPU memory 1 GiB at a time, to demonstrate the VRAM watchdog.

Usage:  python hog_vram.py <target_gib>

Ask SLURM for 4 GB and run this with a target of 10, and the watchdog will
cancel the job shortly after you cross your allocation. That is the point.
"""

import os
import sys
import time

import torch

target = int(sys.argv[1]) if len(sys.argv) > 1 else 10

if not torch.cuda.is_available():
    sys.exit("No GPU visible -- did you use --partition=gpu ?")

print(f"Budget from SLURM: {os.environ.get('GPU_MEM_LIMIT_GB', '?')} GB")
print(f"Going to try for:  {target} GiB\n", flush=True)

blocks = []
for i in range(1, target + 1):
    # 256M float32 elements = exactly 1 GiB
    blocks.append(torch.empty(256 * 1024 * 1024, dtype=torch.float32, device="cuda"))
    torch.cuda.synchronize()
    print(f"  allocated {i} GiB", flush=True)
    time.sleep(2)

print("\nStill alive -- your request was big enough for this workload.")
