"""A CPU workload that scales with the cores it is given.

Used by 04-profile-me.slurm to show what tramuntana-profile does.

It runs for ~30 seconds of genuine computation, which is the minimum the
profiler needs: below that, interpreter start-up and I/O jitter dominate
and the scaling measurements are just noise.
"""

import multiprocessing as mp
import os
import time

import numpy as np

DURATION = 30  # seconds of real work


def work(_):
    a = np.random.rand(512, 512)
    end = time.time() + DURATION
    n = 0
    while time.time() < end:
        a @ a
        n += 1
    return n


if __name__ == "__main__":
    procs = int(os.environ.get("SLURM_CPUS_PER_TASK", "1"))
    print(f"Running on {procs} core(s) for ~{DURATION}s...", flush=True)

    start = time.time()
    with mp.Pool(procs) as pool:
        results = pool.map(work, range(procs))

    print(f"{procs} workers completed {sum(results)} matrix multiplications "
          f"in {time.time() - start:.1f}s")
