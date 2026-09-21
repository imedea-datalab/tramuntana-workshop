# Part 1 — What's new in Tramuntana 2.0

The written version of the workshop slides, in the same order they are presented.
Read it before the workshop, or use it afterwards as a reference.

Each feature section ends with the hands-on exercise that goes with it. We alternate:
feature, then you try it, then the next feature.

**Contents**

| | Section | Hands-on |
|---|---|---|
| 1 | [From 1.0 to 2.0, at a glance](#1-from-10-to-20-at-a-glance) | |
| 2 | [The map: laptop, login node, compute, storage](#2-the-map-laptop-login-node-compute-storage) | |
| 3 | [The nodes](#3-the-nodes) | |
| 4 | [Partitions and limits](#4-partitions-and-limits) | |
| 5 | [Open OnDemand](#5-open-ondemand) | [Exercise 1](02-hands-on.md#exercise-1--everyone-in-through-the-browser) |
| 6 | [The login node is not your laptop](#6-the-login-node-is-not-your-laptop) | [Exercise 2](02-hands-on.md#exercise-2--what-happens-if-you-edit-on-the-login-node) |
| 7 | [Interactive jobs from the terminal](#7-interactive-jobs-from-the-terminal) | [Exercise 3](02-hands-on.md#exercise-3--get-a-shell-on-a-compute-node) |
| 8 | [GPUs are shared now](#8-gpus-are-shared-now) ← the biggest change | [Exercises 4–6](02-hands-on.md#exercise-4--your-first-gpu-job-asked-for-correctly) |
| 9 | [Stop guessing your resources](#9-stop-guessing-your-resources) | [Exercise 7](02-hands-on.md#exercise-7--let-the-profiler-size-the-job-for-you) |
| 10 | [Storage and backups](#10-storage-and-backups) | [Exercise 8](02-hands-on.md#exercise-8--where-your-files-live-and-what-is-protected) |
| 11 | [Documentation, chatbot and monitoring](#11-documentation-chatbot-and-monitoring) | [Exercise 9](02-hands-on.md#exercise-9--ask-the-chatbot) |
| 12 | [A cluster is not a PC](#12-a-cluster-is-not-a-pc) | |
| 13 | [Coming soon](#13-coming-soon) | |
| 14 | [Beyond Tramuntana](#14-beyond-tramuntana) | |

---

## 1. From 1.0 to 2.0, at a glance

| | Tramuntana 1.0 | Tramuntana 2.0 |
|---|---|---|
| Compute nodes | 2 | **7** |
| GPUs | 1 | **4** (176 GB of shareable VRAM) |
| Max cores per job | 64 | **256** |
| Max memory per job | — | **1.5 TB** |
| Max walltime | 3 days | **30 days** |
| GPU requests | whole GPU | **by VRAM** (`--gres=gpu_mem:N`) |
| Backups | none | **nightly, automatic** |
| Web interface | none | **Open OnDemand** |
| Resource sizing | guesswork | **`tramuntana-profile`** |
| OS / scheduler | — | Ubuntu 24.04 LTS, SLURM 23.11.4 |

---

## 2. The map: laptop, login node, compute, storage

Four things, and one rule about each.

**Your laptop.** In the office you are already on the IMEDEA network, over the cable.
From home you need the UIB VPN first. That is the only difference.

**The login node.** You connect here, and only here. Confusingly it is *also* called
`tramuntana`, the same name as the whole cluster — `you@tramuntana` is the login node, not
the cluster. Its job is to be a manager: it knows what CPU, RAM and GPU every compute node has,
and it decides where your work runs. **Never compute here.**

**The compute nodes.** Seven machines where the work actually happens. You never reach them
directly — you ask the login node for an allocation and it puts you on one.

**The storage.** Two shared filesystems, visible from every node *including* the login node,
so you do not need an allocation just to move files around:

| | Size | Per user/group | Backed up? | Put here |
|---|---|---|---|---|
| `/home` | 47 TB SSD | 200 GB per user | **yes, nightly** | scripts, code, anything you would hate to lose |
| `/data` | 200 TB | 15 TB per group | **no** | large datasets, archives |

On top of that, each compute node has its own local disk that is *not* shared — useful as
scratch space for I/O-heavy jobs.

---

## 3. The nodes

### Compute nodes

| Node | Cores | RAM | Special | Best for |
|---|---|---|---|---|
| **ada** | 256 | 768 GB | 7 TB NVMe scratch | Massively parallel CPU work |
| **thor** | 128 | 1.5 TB | 2 × RTX 6000 Ada (48 GB each) | AI/ML, memory-hungry jobs |
| **pampero** | 64 | 384 GB | 40 TB local disk | I/O-heavy work |
| **tramuntana-n1** | 48 | 384 GB | 1 × L40S (48 GB) | General GPU work |
| **barracuda** 🆕 | 20 | 64 GB | 1 × GV100 (32 GB) | GPU testing |
| **vscode-node01** 🆕 | 12 | 14.5 GB | — | Code editing, light interactive |
| **vscode-node02** 🆕 | 8 | 31 GB | — | Code editing, light interactive |

The two `vscode-node`s exist so that editing code and running a notebook no longer competes
with real computation. They are small on purpose. Don't send a training job there.

### Login and storage

| Node | Role |
|---|---|
| **tramuntana** | Login node and SLURM controller. 24 cores. **Never compute here.** |
| **migjorn** | `/home` — 47 TB fast storage |
| **tramuntana-nas** | `/data` — 200 TB bulk storage |
| **io** 🆕 | Backup server — ZFS RAIDZ2 pool holding the Borg repository |

---

## 4. Partitions and limits

| Partition | Nodes | Max time | Priority | Default? |
|---|---|---|---|---|
| **express** | all | 2 hours | 200 (highest) | no |
| **cpu** | all | 30 days | 50 | **yes** |
| **gpu** | thor, tramuntana-n1, barracuda | 30 days | 100 | no |

**If you don't ask, you get:** 1 core, 2 GB RAM, 1 hour.
On the `gpu` partition the memory default is 48 GB.

**Per user:** at most 20 jobs running and 50 jobs queued at once.

Use `express` for anything short. It has the highest priority precisely so that quick tests
don't sit behind week-long simulations.

---

## 5. Open OnDemand

**<https://10.33.0.143/>** — the cluster in your browser. No SSH, no job script.

You must be on the IMEDEA network or connected to the VPN. Log in with your usual IMEDEA username
and password.

### What you can launch

Under **Interactive Apps**:

- **VS Code** — full editor in the browser
- **RStudio** — RStudio Server, with GPU acceleration if you pick a GPU partition
- **MATLAB**
- **AI Chatbot (RAG)** — ask questions about the cluster documentation

There is also a file manager, so moving files around no longer needs `rsync` or FileZilla.

### The launch form

The form is just a SLURM job script with a friendlier face. Each field maps to something you
already know:

| Field | SLURM equivalent |
|---|---|
| Partition | `--partition` |
| Specific node | `--nodelist` |
| Number of hours | `--time` |
| Number of cores (Tasks) | `--cpus-per-task` |
| Memory (GB) per node | `--mem` |
| GPU Memory (GB) | `--gres=gpu_mem:N` |
| Additional SLURM arguments | anything else |

For editing code, pick `vscode-node01` or `vscode-node02` with 2–4 cores. For real computation,
pick `thor`, `ada`, `pampero`, `tramuntana-n1` or `barracuda`.

Click **Launch**, wait for the state to become *Running*, then click **Connect**.

### One thing worth knowing about MATLAB

Choose **MATLAB R2020b**, which runs in an Apptainer container and works on
every node. *MATLAB R2025b (Host Install)* relies on a legacy local installation and will not run on
the newer nodes. Also note MATLAB currently **cannot use the GPU** — the deployed versions have no
Parallel Computing Toolbox, so `gpuArray` and `gpuDeviceCount` will not work even on a GPU node.

### Fixing the certificate warning

Opening a Jupyter notebook inside the web VS Code can show a blank screen and an SSL service-worker
error. Trust the cluster certificate once and it goes away.

**macOS**

```bash
echo -n | openssl s_client -connect 10.33.0.143:443 2>/dev/null | openssl x509 > ~/Desktop/ood.crt
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ~/Desktop/ood.crt
```

**Windows** — open <https://10.33.0.143/>, click the "Not secure" warning → *Certificate is not
valid* → *Details* → *Export*, save as `ood.crt`. Then press the Windows key, type *Manage computer
certificates*, expand **Trusted Root Certification Authorities → Certificates**, right-click →
*All Tasks* → *Import…* and select the file.

Restart your browser afterwards.

> 🧪 **Now do [Exercise 1 — Everyone in, through the browser](02-hands-on.md#exercise-1--everyone-in-through-the-browser).**

---

## 6. The login node is not your laptop

**Remote IDE servers running on `tramuntana` are killed automatically, every 30 seconds.**

This covers VS Code, Cursor, Windsurf, Google Antigravity, JetBrains (PyCharm, IntelliJ…) and
Claude Code.

### Why

VS Code Remote-SSH doesn't just open a terminal. It installs and runs a long-lived server plus one
process per extension on whatever host you connect to. That is fine on a workstation. On a login
node with 24 cores shared by everyone, fifteen of those bring the cluster's front door to its knees —
and then nobody can even submit a job.

### What to do instead

Both of these are fine, and neither is slower than what you were doing:

1. **Open OnDemand's VS Code app** — the section you just read. This is the easy route.
2. **Ask SLURM for an allocation, then connect to the compute node you were given:**

   ```bash
   salloc --partition=cpu --cpus-per-task=4 --mem=16G --time=04:00:00
   squeue -u $USER          # look at the NODELIST column
   ```

   Then point VS Code Remote-SSH at that node (e.g. `vscode-node01`), not at `tramuntana`.

This is allowed, but we don't recommend it unless you have a specific reason: Open OnDemand does
the same thing without the moving parts.

> 🧪 **Now do [Exercise 2 — What happens if you edit on the login node](02-hands-on.md#exercise-2--what-happens-if-you-edit-on-the-login-node).**

---

## 7. Interactive jobs from the terminal

You cannot SSH straight into a compute node, and that is deliberate: if you could, the login node
would not know what resources you were using, and so it could not tell anyone else what is left.
Allocate first, then connect.

| You want to… | Use |
|---|---|
| Run a long script and go home | `sbatch` |
| Get a shell on a compute node right now | `srun --pty bash` |
| Reserve resources and work in them interactively | `salloc` |
| Run one command on a node without writing a file | `srun` |

```bash
# A shell on a compute node, 4 cores, 30 minutes
srun --partition=express --cpus-per-task=4 --mem=8G --time=00:30:00 --pty bash

# Reserve resources for a working session
salloc --partition=cpu --cpus-per-task=8 --mem=32G --time=04:00:00
```

Open OnDemand does exactly this for you in the background — the difference is only whether you
type it or click it.

> 🧪 **Now do [Exercise 3 — Get a shell on a compute node](02-hands-on.md#exercise-3--get-a-shell-on-a-compute-node).**

---

## 8. GPUs are shared now

This is the change most likely to affect a script you already have.

### The problem

A job that needs 6 GB of VRAM used to lock an entire 48 GB GPU. Everyone else waited.

### What changed

On Tramuntana you no longer request *a GPU*. You request *the amount of GPU memory you need*:

```bash
#SBATCH --partition=gpu
#SBATCH --gres=gpu_mem:20      # 20 GB of VRAM
```

Several jobs now share one physical GPU. Internally SLURM tracks this as "shards" of 1 GB each —
`thor` has 96, `tramuntana-n1` has 48, `barracuda` has 32.

Check what is free before you submit:

```bash
check_gpu
```

### Your old scripts still run — but not as you expect

`--gres=gpu:1` (and `--gpus=1`, and `--gres=gpu:l40s:1`) is intercepted and **silently replaced
with 12 GB**. No error, no warning. If your model used to fit and now doesn't, this is why.

Check what you actually got:

```bash
scontrol show job <jobid> | grep -i tres
# TresPerNode=gres/shard:12    ← 12 GB, not a whole GPU
```

### It is enforced

A watchdog runs on every GPU node and checks real VRAM usage every couple of seconds.
**Go over what you asked for and your job is cancelled** — not throttled, not queued. Cancelled.

There is a small tolerance for driver overhead, but that is all. The upside is the same rule
protects you: nobody else can crash your job by over-allocating.

Inside your job you get two environment variables for free:

| Variable | Meaning |
|---|---|
| `GPU_MEM_LIMIT_GB` | How much VRAM you asked for |
| `PYTORCH_CUDA_ALLOC_CONF` | Allocator tuning to reduce fragmentation |

So `echo $GPU_MEM_LIMIT_GB` inside a job tells you your own budget.

### Rules of thumb

| What you're doing | Ask for |
|---|---|
| Small model inference, quick test | `gpu_mem:4` – `gpu_mem:8` |
| Medium model training | `gpu_mem:16` – `gpu_mem:24` |
| Large model needing the whole card | `gpu_mem:48` |

> **Multi-GPU jobs across two cards are not supported yet.** If your model fits in 48 GB you are
> fine. If you need more, talk to Data Lab.

### Peeking at a GPU without disturbing it

To see live GPU usage inside a job you already have running:

```bash
srun --jobid=<jobid> --overlap --pty nvidia-smi
```

To check how busy the GPUs are *before* submitting anything, take the smallest possible slice:

```bash
srun --gres=gpu_mem:1 --time=00:02:00 --partition=gpu --immediate=3 --pty watch -n 1 nvidia-smi
```

`--immediate=3` means: if even 1 GB isn't free within three seconds, give up. If that fails, the
GPUs are full and there is no point queueing a big job right now.

> 🧪 **Now do [Exercise 4 — Your first GPU job](02-hands-on.md#exercise-4--your-first-gpu-job-asked-for-correctly),
> [Exercise 5 — Break it on purpose](02-hands-on.md#exercise-5--break-it-on-purpose) and
> [Exercise 6 — Look at a GPU without disturbing it](02-hands-on.md#exercise-6--look-at-a-gpu-without-disturbing-it).**

---

## 9. Stop guessing your resources

Over-requesting doesn't make your job faster. It makes it wait longer in the queue — and the job it
delays most is usually your own.

### `tramuntana-profile`

Give it your job script. It runs the job, scales CPUs and RAM automatically, measures what was
actually used, and prints back a `#SBATCH` block you can paste in:

```bash
tramuntana-profile -t 30s my-job.slurm
```

Leave `--cpus-per-task`, `--mem` and `--time` **out** of the script you hand it — anything you set
there becomes a ceiling the profiler cannot exceed.

### The everyday commands

```bash
check_gpu        # free GPU memory, per node
check_cpu_ram    # CPU and RAM usage, per node
seff <jobid>     # what a finished job actually used
squeue -u $USER  # your jobs
sacct -j <jobid> --format=JobID,JobName,State,Elapsed,MaxRSS
```

### Environments

- **`uv` is the recommended Python workflow.** `va` is a shortcut for `source .venv/bin/activate`.
- **Conda** still works: `source /data/shared/miniforge3/bin/activate`
- **R**: `source /data/shared/R/setup-R.sh`
- **Apptainer** is on the global `PATH` for containers.

> 🧪 **Now do [Exercise 7 — Let the profiler size the job for you](02-hands-on.md#exercise-7--let-the-profiler-size-the-job-for-you).**

---

## 10. Storage and backups

**`/home` is backed up. `/data` is not.**

| | |
|---|---|
| **What** | Everything in `/home` |
| **When** | Every night at 02:00 |
| **How** | Borg, from `migjorn` to a ZFS RAIDZ2 pool on the `io` server |
| **Kept** | ~7 daily, 4 weekly and 6 monthly snapshots |
| **Not included** | `~/.cache`, trash, `~/.npm`, browser caches |

Backups are deduplicated and compressed, and the system is monitored: Grafana raises an alert if a
backup fails, if none has run for 24 hours, if the pool passes 80 % full, or if a disk degrades or
fails.

### If you lose something

**Restores go through Data Lab** — they are not self-service. Email
servicio_datalab@imedea.uib-csic.es with the path and roughly when the file was last good. Snapshots
are per night, so the more precisely you can date it, the better.

### The part that should change your behaviour

`/data` holds 200 TB of group datasets and **has no backup at all**. If the only copy of something
irreplaceable lives there, that is a decision you are making. Raw data that could not be collected
again belongs somewhere with a second copy.

> 🧪 **Now do [Exercise 8 — Where your files live, and what is protected](02-hands-on.md#exercise-8--where-your-files-live-and-what-is-protected).**

---

## 11. Documentation, chatbot and monitoring

The cluster documentation is public and rewritten:

**<https://imedea-datalab.github.io/tramuntana-docs/>**

| Guide | What it covers |
|---|---|
| Quick Start & Commands | SSH, SLURM, GPUs, job management — the cheat sheet |
| Open OnDemand | Launching MATLAB, VS Code and RStudio from the browser |
| Advanced Commands & Monitoring | Job arrays, GPU monitoring, resource checks |
| Software & Environments | `uv`, Conda, R and RStudio |
| Under the Hood (1–4) | What a cluster is, SLURM, connecting, the file system |

Start with **Quick Start** if you just want to run something, or **Under the Hood** if you want to
understand what is happening underneath.

### The AI chatbot

Under **Interactive Apps → AI Chatbot (RAG)** in Open OnDemand. It answers questions about this
documentation, and every answer cites the sections it came from — that is its best use, finding
where something is written down.

Two quirks to know before you rely on it:

- The first question after an idle period takes **3–4 minutes** while the models load into GPU
  memory. After that answers are fast for 30 minutes, then the backend shuts down to free the GPU.
- It has **no conversation memory**. Every question is standalone, so include the context you need
  in the question itself.

### Monitoring

Grafana dashboards show CPU, memory and GPU usage for every node, so you can see whether a GPU is
genuinely free before you queue a job.

> 🧪 **Now do [Exercise 9 — Ask the chatbot](02-hands-on.md#exercise-9--ask-the-chatbot).**

---

## 12. A cluster is not a PC

Worth saying plainly, because it is the source of most disappointment:

- **No state.** When your allocation ends, your session is gone — open windows, running
  applications, all of it. Reconnecting does not bring them back.
- **It is a job allocator first.** The interactive side (VS Code, RStudio, MATLAB in the browser)
  is a convenience layered on top, not the main purpose.
- **No direct SSH to compute nodes.** Allocate first, always.

**If you need a persistent machine, you need a PC.** And if that PC runs Linux, we can mount your
`/home` and `/data` on it, so you get the storage without pretending the cluster is a desktop.

---

## 13. Coming soon

- **Apptainer for everything.** We are moving software into containers so you can pick your own
  compiler, library or language version on a compute node without coming to us each time.
- **Windows instructions** throughout the documentation.
- **More environments** supported out of the box.

---

## 14. Beyond Tramuntana

Tramuntana is now big enough for most day-to-day work. The reason to go elsewhere is scale, a tape
archive, or a very large AI model — not capability in general.

| | **Tramuntana** | **Drago** (CSIC) | **talaIA** (UIB) | **RES** (national) |
|---|---|---|---|---|
| Scale | 7 nodes | 283 nodes | 61 nodes | 14 centres |
| CPU | 256 cores max | 250 × 48c, 22 × 96c | 52 × 192c EPYC | varies |
| Memory | up to 1.5 TB | 192 GB – 2 TB | 768 GB – 2 TB | varies |
| GPU | 4 (L40S, 2× RTX 6000 Ada, GV100) | 64× H200, 8× A100, 2× L40S | 16× B200, 10× H200, 16× L40S | dedicated AI call |
| Storage | 47 TB + 200 TB | Lustre 500 TB SSD, ~5 PB disk, 12 PB tape | 2 PB BeeGFS | ≥200 TB data call |
| Network | 10 GbE back-end | InfiniBand HDR | InfiniBand NDR | varies |
| Access | ask Data Lab | CSIC account, `drago.csic.es` | request through UIB | competitive call |

**Stay on Tramuntana when** you're doing everyday analysis or GPU development, your jobs fit in
30 days, and you want to start today.

**Look elsewhere when** you need hundreds of nodes, 2 TB of RAM in one job, many large GPUs, or a
tape archive.

Links: [Drago](https://docaic.rstools.csic.es/computacion) ·
[talaIA](https://bsai.uib.es/caracteristiques-tecniques) · [RES](https://www.res.es/)

> RES access is by competitive call: HPC/AI calls run twice a year, with a fast track always open.

---

**The exercises:** [Part 2 — Hands-on](02-hands-on.md)
