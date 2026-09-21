# Part 2 — Hands-on

Nine short exercises, interleaved with the slides. After each new feature we stop and you try it,
then we move on. Everything you need is in [`exercises/`](exercises/).

Nothing here assumes you have used SLURM before. The first exercise happens entirely in a browser.
If you get stuck at any point, put a hand up — falling behind on exercise 4 makes exercise 5
meaningless, and we would rather stop than leave you behind.

**Setup** — on the login node, once:

```bash
git clone https://github.com/imedea-datalab/tramuntana-workshop.git
cd tramuntana-workshop/exercises
```

| # | After the section on… | Exercise | Time |
|---|---|---|---|
| 1 | [Open OnDemand](01-whats-new.md#5-open-ondemand) | [Everyone in, through the browser](#exercise-1--everyone-in-through-the-browser) | 10 min |
| 2 | [The login node](01-whats-new.md#6-the-login-node-is-not-your-laptop) | [What happens if you edit on the login node](#exercise-2--what-happens-if-you-edit-on-the-login-node) | 8 min |
| 3 | [Interactive jobs](01-whats-new.md#7-interactive-jobs-from-the-terminal) | [Get a shell on a compute node](#exercise-3--get-a-shell-on-a-compute-node) | 7 min |
| 4 | [GPUs are shared](01-whats-new.md#8-gpus-are-shared-now) | [Your first GPU job, asked for correctly](#exercise-4--your-first-gpu-job-asked-for-correctly) | 15 min |
| 5 | ” | [Break it on purpose](#exercise-5--break-it-on-purpose) | 18 min |
| 6 | ” | [Look at a GPU without disturbing it](#exercise-6--look-at-a-gpu-without-disturbing-it) | 10 min |
| 7 | [The profiler](01-whats-new.md#9-stop-guessing-your-resources) | [Let the profiler size the job for you](#exercise-7--let-the-profiler-size-the-job-for-you) | 20 min |
| 8 | [Storage and backups](01-whats-new.md#10-storage-and-backups) | [Where your files live, and what is protected](#exercise-8--where-your-files-live-and-what-is-protected) | 7 min |
| 9 | [Docs and chatbot](01-whats-new.md#11-documentation-chatbot-and-monitoring) | [Ask the chatbot](#exercise-9--ask-the-chatbot) | 5 min |

---

## Exercise 1 — Everyone in, through the browser

**Goes with:** [§5 Open OnDemand](01-whats-new.md#5-open-ondemand)

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

## Exercise 2 — What happens if you edit on the login node

**Goes with:** [§6 The login node is not your laptop](01-whats-new.md#6-the-login-node-is-not-your-laptop)

**Goal:** see the policy in action, so it isn't a surprise later.

**We run this one together as a demo** — fifteen simultaneous attempts is not a good idea.

1. From your laptop, connect VS Code Remote-SSH directly to `tramuntana`.
2. Wait about thirty seconds.
3. The connection drops.

On the cluster side, the kill is logged:

```bash
grep IDE_KILLER /var/log/syslog
```

Then, immediately, the right way: back to Open OnDemand from exercise 1, same editor, same files,
running on `vscode-node01` where it belongs.

Same work. One version takes the login node down for everyone; the other doesn't.

---

## Exercise 3 — Get a shell on a compute node

**Goes with:** [§7 Interactive jobs from the terminal](01-whats-new.md#7-interactive-jobs-from-the-terminal)

**Goal:** do by hand what Open OnDemand did for you in exercise 1, so you know what it is doing.

From the login node:

```bash
hostname                 # tramuntana -- you are on the login node

srun --partition=express --cpus-per-task=2 --mem=4G --time=00:15:00 --pty bash

hostname                 # a compute node -- ada, pampero, thor...
nproc                    # 2, not the node's real core count
```

You are inside an allocation. `nproc` reports what SLURM gave you, not what the machine has —
that is the cgroup doing its job.

Leave it with `exit`, and confirm the allocation is gone:

```bash
exit
squeue -u $USER          # empty
```

Now try the same thing without allocating anything:

```bash
ssh ada
```

It refuses. That is the rule from the slides, enforced: no allocation, no compute node.

---

## Exercise 4 — Your first GPU job, asked for correctly

**Goes with:** [§8 GPUs are shared now](01-whats-new.md#8-gpus-are-shared-now)

**Goal:** submit a GPU job the 2.0 way, and prove the allocation reached your code.

First, look at what's free:

```bash
check_gpu
```

Then submit [`04-first-gpu-job.slurm`](exercises/04-first-gpu-job.slurm):

```bash
sbatch 04-first-gpu-job.slurm
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
using all of it? (Exercise 5.)

---

## Exercise 5 — Break it on purpose

**Goes with:** [§8 GPUs are shared now](01-whats-new.md#8-gpus-are-shared-now)

**Goal:** experience both failure modes, deliberately, in a safe place.

### 5a. Exceed your request

[`05a-oom-watchdog.slurm`](exercises/05a-oom-watchdog.slurm) asks for **4 GB** and then tries to
allocate **10 GB**:

```bash
sbatch 05a-oom-watchdog.slurm
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

### 5b. The legacy trap

[`05b-legacy-syntax.slurm`](exercises/05b-legacy-syntax.slurm) uses the **old** `--gres=gpu:1`
syntax. Submit it and, while it runs, inspect what SLURM actually gave you:

```bash
sbatch 05b-legacy-syntax.slurm
scontrol show job <jobid> | grep -i tres
```

You asked for a whole GPU. You have:

```
TresPerNode=gres/shard:12
```

**12 GB.** No error, no warning. Now go and check your own scripts — `grep -r "gres=gpu" ~` is a
good start.

---

## Exercise 6 — Look at a GPU without disturbing it

**Goes with:** [§8 GPUs are shared now](01-whats-new.md#8-gpus-are-shared-now)

**Goal:** two habits worth keeping.

**Inside a job you already have running** (start one from exercise 4 first, with a longer
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

## Exercise 7 — Let the profiler size the job for you

**Goes with:** [§9 Stop guessing your resources](01-whats-new.md#9-stop-guessing-your-resources)

**Goal:** stop guessing.

[`07-profile-me.slurm`](exercises/07-profile-me.slurm) runs a CPU workload that scales with the
cores it is given. Note that it deliberately sets **no** `--cpus-per-task`, `--mem` or `--time` —
those would be ceilings the profiler cannot exceed.

```bash
tramuntana-profile -t 30s 07-profile-me.slurm
```

It will run the job several times, doubling cores while that still buys speed, and recovering
automatically if it runs out of memory. At the end it prints a recommended `#SBATCH` block.

Now compare against a badly-sized version. Submit the same work asking for far too much:

```bash
sbatch --cpus-per-task=64 --mem=200G 07-profile-me.slurm
```

then check what it really used:

```bash
seff <jobid>
```

Look at the efficiency percentages. That gap between requested and used is time your job spent
waiting in the queue for resources it never touched.

---

## Exercise 8 — Where your files live, and what is protected

**Goes with:** [§10 Storage and backups](01-whats-new.md#10-storage-and-backups)

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

## Exercise 9 — Ask the chatbot

**Goes with:** [§11 Documentation, chatbot and monitoring](01-whats-new.md#11-documentation-chatbot-and-monitoring)

**Goal:** know when the chatbot is the fastest way to an answer, and when it isn't.

In Open OnDemand: **Interactive Apps → AI Chatbot (RAG)** → **Launch** → **Connect**.

> The first question after an idle period takes **3–4 minutes** while the models load. Start it
> going, then come back to it.

Ask it something you now know the answer to, so you can judge the quality:

```
How do I request GPU memory instead of a whole GPU?
```

Then ask something you don't:

```
How do I run a job array?
```

**What to look at:** the citations under the answer. Those are the documentation sections it read.
Open one. The citation is usually more valuable than the answer — it tells you where the real
reference lives.

**What not to do:** follow-up questions. It has no conversation memory, so "and what about R?"
will be answered as if you had asked nothing before. Repeat the full context each time.

---

## Where to go next

- **Documentation:** <https://imedea-datalab.github.io/tramuntana-docs/>
- **The written version:** [Part 1 — What's new](01-whats-new.md)
- **Questions:** servicio_datalab@imedea.uib-csic.es

Two things we would ask of you this week:

1. `grep` your existing scripts for `--gres=gpu:` and convert them to `gpu_mem`.
2. If you edit code on the cluster, move that workflow to Open OnDemand.
