# Part 2 — Hands-on

Six exercises, 11:30–13:00. Everything you need is in [`exercises/`](exercises/).

Nothing here assumes you have used SLURM before. The first exercise happens entirely in a browser.
If you get stuck at any point, put a hand up — falling behind on exercise 2 makes exercise 3
meaningless, and we would rather stop than leave you behind.

**Setup** — on the login node, once:

```bash
git clone https://github.com/imedea-datalab/tramuntana-workshop.git
cd tramuntana-workshop/exercises
```

| # | Exercise | Time |
|---|---|---|
| 0 | [Everyone in, through the browser](#exercise-0--everyone-in-through-the-browser) | 10 min |
| 1 | [Your first GPU job, asked for correctly](#exercise-1--your-first-gpu-job-asked-for-correctly) | 15 min |
| 2 | [Break it on purpose](#exercise-2--break-it-on-purpose) | 18 min |
| 3 | [Look at a GPU without disturbing it](#exercise-3--look-at-a-gpu-without-disturbing-it) | 12 min |
| 4 | [Let the profiler size the job for you](#exercise-4--let-the-profiler-size-the-job-for-you) | 20 min |
| 5 | [What happens if you edit on the login node](#exercise-5--what-happens-if-you-edit-on-the-login-node) | 8 min |
| 6 | [Where your files live, and what is protected](#exercise-6--where-your-files-live-and-what-is-protected) | 7 min |

---

## Exercise 0 — Everyone in, through the browser

**Goal:** every person in the room running code on a compute node, within ten minutes, without
touching a terminal.

1. Go to **<https://10.33.0.143/>** and log in with your IMEDEA username and password.
2. **Interactive Apps → VS Code**.
3. Fill in the form:
   - Partition: `cpu`
   - Specific node: `vscode-node01`
   - Number of hours: `2`
   - Number of cores: `2`
   - Memory (GB): `4`
4. **Launch**. Wait for *Running*, then **Connect**.
5. In the VS Code terminal, run:

   ```bash
   hostname
   ```

You should see `vscode-node01` — not `tramuntana`. **You are on a compute node.** Everything from
here could have been done this way.

> **If you see a blank screen opening a notebook**, that's the certificate issue.
> [Part 1 has the fix](01-whats-new.md#fixing-the-certificate-warning) for macOS and Windows.

---

## Exercise 1 — Your first GPU job, asked for correctly

**Goal:** submit a GPU job the 2.0 way, and prove the allocation reached your code.

First, look at what's free:

```bash
check_gpu
```

Then submit [`01-first-gpu-job.slurm`](exercises/01-first-gpu-job.slurm):

```bash
sbatch 01-first-gpu-job.slurm
squeue -u $USER
```

When it finishes, read the output:

```bash
cat first-gpu-*.out
```

**What to look for:**

- `GPU_MEM_LIMIT_GB` prints `8` — the prolog ran and your job knows its own budget.
- `nvidia-smi` shows the physical card, which may be much bigger than 8 GB, and may well show
  **other people's processes on it**. That is the point: the GPU is shared.

**Question to sit with:** `nvidia-smi` reports the whole card. So what is actually stopping you from
using all of it? (Exercise 2.)

---

## Exercise 2 — Break it on purpose

**Goal:** experience both failure modes, deliberately, in a safe place.

### 2a. Exceed your request

[`02-oom-watchdog.slurm`](exercises/02-oom-watchdog.slurm) asks for **4 GB** and then tries to
allocate **10 GB**:

```bash
sbatch 02-oom-watchdog.slurm
squeue -u $USER          # watch it
```

It will disappear within seconds. Find out what happened:

```bash
sacct -j <jobid> --format=JobID,JobName,State,ExitCode,Elapsed
cat oom-*.out            # see how far it got before being killed
```

The output shows it allocating 1 GiB at a time and stopping shortly after passing 4 GiB.

Now fix it — change `gpu_mem:4` to `gpu_mem:12` in the script and resubmit. Same code, honest
request, job completes.

> This is the single most useful thing to have experienced before it happens to you at 2 a.m. on
> real work.

### 2b. The legacy trap

[`03-legacy-syntax.slurm`](exercises/03-legacy-syntax.slurm) uses the **old** `--gres=gpu:1` syntax.
Submit it and, while it runs, inspect what SLURM actually gave you:

```bash
sbatch 03-legacy-syntax.slurm
scontrol show job <jobid> | grep -i tres
```

You asked for a whole GPU. You have:

```
TresPerNode=gres/shard:12
```

**12 GB.** No error, no warning. Now go and check your own scripts — `grep -r "gres=gpu" ~` is a
good start.

---

## Exercise 3 — Look at a GPU without disturbing it

**Goal:** two habits worth keeping.

**Inside a job you already have running** (start one from exercise 1 first, with a longer
`--time`):

```bash
srun --jobid=<jobid> --overlap --pty nvidia-smi
```

`--overlap` means "share my existing allocation" rather than requesting new resources.

**Before submitting anything** — the one-gigabyte eavesdrop:

```bash
srun --gres=gpu_mem:1 --time=00:02:00 --partition=gpu --immediate=3 --pty watch -n 1 nvidia-smi
```

Press `Ctrl-C` to leave.

If this returns immediately without giving you a session, even 1 GB was unavailable: the GPUs are
completely full, and queueing a large job right now would just mean waiting.

---

## Exercise 4 — Let the profiler size the job for you

**Goal:** stop guessing.

[`04-profile-me.slurm`](exercises/04-profile-me.slurm) runs a CPU workload that scales with the
cores it is given. Note that it deliberately sets **no** `--cpus-per-task`, `--mem` or `--time` —
those would be ceilings the profiler cannot exceed.

```bash
tramuntana-profile -t 30s 04-profile-me.slurm
```

It will run the job several times, doubling cores while that still buys speed, and recovering
automatically if it runs out of memory. At the end it prints a recommended `#SBATCH` block.

Now compare against a badly-sized version. Submit the same work asking for far too much:

```bash
sbatch --cpus-per-task=64 --mem=200G 04-profile-me.slurm
```

then check what it really used:

```bash
seff <jobid>
```

Look at the efficiency percentages. That gap between requested and used is time your job spent
waiting in the queue for resources it never touched.

---

## Exercise 5 — What happens if you edit on the login node

**Goal:** see the policy in action, so it isn't a surprise later.

**We run this one together as a demo** — fifteen simultaneous attempts is not a good idea.

1. From your laptop, connect VS Code Remote-SSH directly to `tramuntana`.
2. Wait about thirty seconds.
3. The connection drops.

On the cluster side, the kill is logged:

```bash
grep IDE_KILLER /var/log/syslog
```

Then, immediately, the right way: back to Open OnDemand from exercise 0, same editor, same files,
running on `vscode-node01` where it belongs.

Same work. One version takes the login node down for everyone; the other doesn't.

---

## Exercise 6 — Where your files live, and what is protected

**Goal:** know what would survive a mistake.

Check your quota and where your space is going:

```bash
df -h /home /data
du -sh ~/* | sort -h | tail
```

Then the important part. `/home` is backed up nightly; `/data` is not.

Ask yourself one question and answer it honestly: **is there anything in `/data` that could not be
regenerated or re-collected?** If yes, that data currently has exactly one copy. Talk to Data Lab
about it today rather than after a disk failure.

If you ever need a restore, it goes through Data Lab — email
servicio_datalab@imedea.uib-csic.es with the path and roughly when the file was last good.

---

## Where to go next

- **Documentation:** <https://imedea-datalab.github.io/tramuntana-docs/>
- **These slides:** [Canva](https://www.canva.com/design/DAHSopfTDkc/IlSxTvrYS7Stkw78Sa_Qxw/view)
- **The written version:** [Part 1 — What's new](01-whats-new.md)
- **Questions:** servicio_datalab@imedea.uib-csic.es

Two things we would ask of you this week:

1. `grep` your existing scripts for `--gres=gpu:` and convert them to `gpu_mem`.
2. If you edit code on the cluster, move that workflow to Open OnDemand.
