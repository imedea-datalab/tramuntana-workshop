# Tramuntana 2.0 — Workshop

**What's new on the Tramuntana HPC cluster**
Data Lab · IMEDEA UIB-CSIC

Instructors: Roberto Alcaraz & Akshay Tiwari
Venue: IMEDEA Seminar Room & online · Language: English

---

## What this repository is

Everything you need for the Tramuntana 2.0 workshop, in one place:

| | |
|---|---|
| 📖 **[Part 1 — What's new](01-whats-new.md)** | Written version of the slides, with all the detail that doesn't fit on a slide |
| 🧪 **[Part 2 — Hands-on](02-hands-on.md)** | The nine exercises, each one right after the feature it belongs to |
| 📂 **[`exercises/`](exercises/)** | Ready-to-run job scripts for the practical part |

Both parts follow the same order as the slides.

Full cluster documentation lives at
**<https://imedea-datalab.github.io/tramuntana-docs/>**

---

## How the day runs

Theory and practice are **interleaved**: we present one new feature, you try it, then we move to
the next. There is no separate hands-on block at the end.

| | Feature | You try |
|---|---|---|
| 09:45 | Welcome, 1.0 → 2.0, the map, the nodes, partitions | — |
| 10:15 | **Open OnDemand** | Exercise 1 — everyone in, through the browser |
| 10:35 | **The login node is not your laptop** | Exercise 2 — watch the editor get killed |
| 10:50 | **Interactive jobs** | Exercise 3 — get a shell on a compute node |
| 11:05 | *Coffee break* | |
| 11:20 | **GPUs are shared now** | Exercises 4, 5, 6 — ask correctly, break it, peek |
| 12:05 | **`tramuntana-profile`** | Exercise 7 — let the profiler size the job |
| 12:25 | **Storage and backups** | Exercise 8 — what would survive a mistake |
| 12:35 | **Docs, chatbot, monitoring** | Exercise 9 — ask the chatbot |
| 12:45 | A cluster is not a PC · Coming soon · Beyond Tramuntana · Questions | — |

---

## Before you arrive

Please do these three things — they take five minutes and save fifteen in the room.

1. **Check you can reach the cluster.** You need to be on the IMEDEA network, or connected to the VPN.

2. **Open Open OnDemand once**, at **<https://10.33.0.143/>**, and log in with your usual IMEDEA
   username and password. Your browser will warn about the certificate — that is expected, and
   [Part 1 explains how to fix it properly](01-whats-new.md#fixing-the-certificate-warning).

3. **Clone this repository onto the cluster**, so the exercise scripts are ready:

   ```bash
   git clone https://github.com/imedea-datalab/tramuntana-workshop.git
   cd tramuntana-workshop/exercises
   ```

---

## The short version

If you only remember five things:

1. **Ask for GPU memory, not for a GPU.** `--gres=gpu_mem:20`, not `--gres=gpu:1`.
2. **Exceeding your GPU memory request cancels your job**, within seconds.
3. **Don't run your editor on the login node.** It gets killed automatically. Use Open OnDemand.
4. **Stop guessing resources** — `tramuntana-profile` works them out for you.
5. **`/home` is backed up nightly. `/data` is not.**

---

## Questions

servicio_datalab@imedea.uib-csic.es
