# Exercise files

Job scripts and helpers for [Part 2 — Hands-on](../02-hands-on.md).
The numbers match the exercise numbers, which in turn match the order of the slides.

| File | Used in | What it does |
|---|---|---|
| `04-first-gpu-job.slurm` | Exercise 4 | A correct GPU job — asks for 8 GB of VRAM and shows what it got |
| `05a-oom-watchdog.slurm` | Exercise 5a | Asks for 4 GB, tries to use 10, gets cancelled |
| `05b-legacy-syntax.slurm` | Exercise 5b | Uses the old `--gres=gpu:1` and shows the silent 12 GB downgrade |
| `07-profile-me.slurm` | Exercise 7 | Deliberately unsized job for `tramuntana-profile` |
| `hog_vram.py` | Exercise 5a | Allocates GPU memory 1 GiB at a time |
| `cpu_work.py` | Exercise 7 | CPU workload that scales with available cores |

Exercises 1, 2, 3, 6, 8 and 9 need no files — they are run from the browser or straight
from the command line.

Submit any of them with `sbatch <file>`, except `07-profile-me.slurm`, which is meant to be
run through the profiler:

```bash
tramuntana-profile -t 30s 07-profile-me.slurm
```
