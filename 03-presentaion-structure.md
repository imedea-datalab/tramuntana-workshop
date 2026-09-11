# Presentation Structure

## 1. Before Start
- **Start by warning that due to load things may fail**: Give them the docs and OOD URL.
- **Tell reasons to read the docs**:
  - It will make you better at using the server.
  - If you frequently do simulation or computation, it's good to know how it works.
  - If you want to use another, bigger cluster, they all use the same commands and structure.

---

## 2. Visual Explanations
- All explaining with visuals (like the last 3 slides Roberto prepared with *dibujos* / diagrams).

---

## 3. Two Ways to Use Cluster: GUI or Code

### 3.1 Code (CLI)
> If you use the Code one you get full freedom to get maximum out of the cluster, but there are prerequisites and a learning curve. We will show a short intro to SSH so you can get up and running, and details are in the docs:

- Show `~/.ssh/config` to add Tramuntana as its IP in local laptop and keygen for passwordless login.
- How to transfer data: `scp` or `rsync`.
- Explain how storage works, backups, and quotas.
- Small walkthrough on `.slurm` file (partitions, nodes, their names, and capacity).
- For Windows instructions, tell them to open docs.

### 3.2 GUI Ways to Use Cluster
- Showing Open OnDemand built-in VS Code and terminal (no need to SSH, etc.).
- Helper interactive nodes: `vscode-01` and `vscode-02`.

---

## 4. Cluster is Not Your PC
- You **CANNOT** direct-SSH into compute nodes anymore.
- The **Login Node is NOT a compute node**.
  - Login node useful commands: `check_cpu_ram`, `squeue`, etc.

---

## 5. Using GPU and Memory

---

## 6. Peeking on Your Job Resource Usage

---

## 7. `tramuntana-profile`
- Profiling and performance analysis: GPU, CPU, memory.

---

## 8. Explaining `uv` for Python

---

## 9. Things Left to Do and Will Be Available Soon
- We are still organising and putting things in Apptainer.
  - So that when you run a program locally (Python, R, etc.), you can install whatever compiler, library, or version of your choice in the compute node and don't have to come to us every time.

---

## 10. Recording
> [!NOTE]
> Record the presentation to put later on YouTube.

