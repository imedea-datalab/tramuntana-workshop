# Exercise files

Job scripts and helpers for [Part 2 — Hands-on](../02-hands-on.md).

| File | Used in | What it does |
|---|---|---|
| `01-first-gpu-job.slurm` | Exercise 1 | A correct GPU job — asks for 8 GB of VRAM and shows what it got |
| `02-oom-watchdog.slurm` | Exercise 2a | Asks for 4 GB, tries to use 10, gets cancelled |
| `03-legacy-syntax.slurm` | Exercise 2b | Uses the old `--gres=gpu:1` and shows the silent 12 GB downgrade |
| `04-profile-me.slurm` | Exercise 4 | Deliberately unsized job for `tramuntana-profile` |
| `hog_vram.py` | Exercise 2a | Allocates GPU memory 1 GiB at a time |
| `cpu_work.py` | Exercise 4 | CPU workload that scales with available cores |

Submit any of them with `sbatch <file>`, except `04-profile-me.slurm`, which is meant to be
run through the profiler:

```bash
tramuntana-profile -t 30s 04-profile-me.slurm
```
