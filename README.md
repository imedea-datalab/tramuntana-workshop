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
| 📊 **[Slides (Canva)](https://www.canva.com/design/DAHSopfTDkc/IlSxTvrYS7Stkw78Sa_Qxw/view)** | The presentation used in the morning session |
| 📖 **[Part 1 — What's new](01-whats-new.md)** | Written version of the slides, with all the detail that doesn't fit on a slide |
| 🧪 **[Part 2 — Hands-on](02-hands-on.md)** | The exercises we run after the coffee break |
| 📂 **[`exercises/`](exercises/)** | Ready-to-run job scripts for the practical part |

Full cluster documentation lives at
**<https://imedea-datalab.github.io/tramuntana-docs/>**

---

## Schedule

| Time | |
|---|---|
| 09:45 – 11:15 | Presenting the new updates |
| 11:15 – 11:30 | Coffee break |
| 11:30 – 13:00 | Hands-on session |

---

## Before you arrive

Please do these three things — they take five minutes and save fifteen in the room.

1. **Check you can reach the cluster.** You need to be on the IMEDEA network, or connected to the VPN.

2. **Open Open OnDemand once**, at **<https://10.33.0.143/>**, and log in with your usual IMEDEA username and password. Your browser will warn about the certificate — that is expected, and [Part 1 explains how to fix it properly](01-whats-new.md#fixing-the-certificate-warning).

3. **Clone this repository onto the cluster**, so the exercise scripts are ready:

   ```bash
   ssh <your-username>@tramuntana
   git clone https://github.com/imedea-datalab/tramuntana-workshop.git
   cd tramuntana-workshop
   ```

If you have never used the cluster before, don't worry — the hands-on session starts from zero, in the browser, with no terminal required.

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
