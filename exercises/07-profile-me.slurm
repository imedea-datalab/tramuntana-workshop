#!/bin/bash
#SBATCH --job-name=profile-me
#SBATCH --output=profile-%j.out
#SBATCH --error=profile-%j.err

# Deliberately minimal: no --cpus-per-task, no --mem, no --time.
# Anything you set here becomes a CEILING the profiler cannot exceed.
#
# Run with:   tramuntana-profile -t 30s 07-profile-me.slurm

uv run --with numpy python cpu_work.py
