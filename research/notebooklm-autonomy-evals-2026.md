Answer:
### 1. Agent Autonomy Levels & Freedom

Karpathy frames agent autonomy along a spectrum ranging from **partial autonomy 
("on the leash")** to **fully autonomous execution loops**, matching the 
autonomy level to the verifiability and risk profile of the task [1-3].

#### The Three Levels of Agent Freedom
* **On-the-Leash (Supervised / Interactive Mode)**:
  * **When to use**: Architectural design, security-sensitive boundaries, data 
schema modeling, and non-verifiable logic choices [2, 4, 5].
  * **What it means**: The human engineer acts as a **system architect and 
creative director** [6]. You maintain strict oversight, review line-by-line 
diffs, update repository context instructions (`CLAUDE.md`), and set approval 
gates before executing destructive bash or database actions [2, 3, 7].
  * **Concrete example**: Design decisions such as identity architecture. In 
Karpathy’s *MenuGen* app, an agent attempted to link Stripe payments and Google 
accounts by matching arbitrary email addresses instead of using persistent user 
IDs [4, 5, 8]. Karpathy points out that human oversight ("taste and judgment") 
must keep the agent on a leash to catch these subtle logic flaws [5, 9].
* **Autopilot (Guided Multi-Step Execution)**:
  * **When to use**: Well-scoped features, multi-file refactoring, and task 
execution with programmatic success criteria [10-12].
  * **What it means**: The developer provides declarative goals rather than 
step-by-step imperative commands [11, 12]. The agent plans, executes tool calls,
reads environment outputs, and debugs in a loop, while the human steps in only 
at specified checkpoints [12-14].
  * **Concrete example**: The **OpenClaw installer pattern**. Instead of writing
a complex 500-line cross-platform bash script, Karpathy ships plain-text 
runbooks [13, 15, 16]. The agent reads the local machine environment, installs 
dependencies, and debugs setup issues autonomously [13, 15, 17].
* **Fully Autonomous (Unattended Swarms)**:
  * **When to use**: Closed-loop research, hyperparameter tuning, and benchmarks
with explicit programmatic verifiers [18-20].
  * **What it means**: The agent runs completely unattended in an isolated 
environment (e.g., overnight), continuously modifying code, evaluating execution
metrics against a fixed reward function, and committing or reverting changes 
autonomously [18, 20, 21].
  * **Concrete example**: Karpathy’s `autoresearch` framework, where AI agents 
autonomously run training experiments on a single GPU for 5-minute fixed 
budgets, evaluating validation loss (`val_bpb`), and keeping or discarding 
commits without human intervention [18, 20, 22].

---

### 2. Concrete Verification & Eval Practices

Karpathy's core automation principle states:  
> **"Traditional software automates what you can specify in code. LLMs and 
reinforcement learning automate what you can verify."** [19, 23, 24]

#### The Three Conditions for Verifiability
To build reliable agent workflows, Karpathy defines three structural conditions 
for verification [25]:
1. **Resettable**: The environment must be able to cleanly reset to a baseline 
state so tests or runs can be repeated indefinitely [25].
2. **Efficient**: The feedback loop must execute quickly (e.g., fast test 
suites, 5-minute training runs, rapid linting) so agents can iterate rapidly 
[22, 25].
3. **Rewardable**: Output correctness must yield unambiguous programmatic 
scores, compiler pass/fail signals, or evaluation metrics [19, 25, 26].

#### Evals and Verification Loops in Practice
* **Test-Driven Success Criteria**: Instead of telling an agent *"Fix the bug"*,
Karpathy advocates transforming instructions into declarative, testable goals: 
*"Write a failing test that reproduces the bug, then write the code to make it 
pass."* [11, 12]
* **Crude Eval Harnesses**: Before deploying agents or opening slopgates, teams 
should build evaluation harnesses—even crude ones using LLM-as-judge panels or 
5–10 sample test sets—to catch logic regressions [2, 27, 28].
* **Adversarial "Agent Rodeo" Verification**: When reviewing or hiring for 
agentic capability, Karpathy suggests replacing LeetCode puzzles with 
adversarial verification [29-31]:
  > **"Hiring should look like: give me a really big project... write a Twitter 
clone for agents, make it secure, have agents simulate activity, and then I'm 
going to use 10 Codex instances to try to break your website... and they should 
not be able to break it."** [29, 31, 32]

---

### 3. Recent 2026 Shift, Tools/Repos, and Top Do's & Don'ts

#### What Changed: December 2025 Inflection Point
In early 2025, Karpathy introduced **"vibe coding"** as a lighthearted term for 
prompt-driven prototyping where developers *"fully give in to the vibes... 
'Accept All' always, don't read the diffs anymore, and forget that the code even
exists"* [33-35].

By early 2026 (at Sequoia Capital's AI Ascent 2026), he retired vibe coding as a
production practice and introduced **"agentic engineering"** [33, 36-38]. He 
identified **December 2025** as the stark phase change when frontier models 
began reliably outputting large, multi-step code blocks without breaking 
[39-41]:
> **"Vibe coding raises the floor. Agentic engineering raises the ceiling."** 
[2, 38, 42, 43]
* *Vibe coding* democratizes building so anyone can ship weekend side projects 
[2, 38, 43].
* *Agentic engineering* preserves the professional software ceiling—ensuring 
security, maintainability, and code quality while achieving multi-agent leverage
far beyond the old "10x engineer" metric [2, 38, 42, 44].

#### Key 2026 Repositories & Tools Mentioned
* **`autoresearch` (March 2026)**: An autonomous AI agent research harness where
agents run single-GPU ML training trials on `nanochat` [18, 21, 45]. Humans 
program the meta-instruction file (`program.md`), while the agent touches 
`train.py` [18, 21].
* **`nanochat`**: Karpathy's lightweight repository demonstrating full-lifecycle
GPT-2 level conversational model pretraining, SFT, and evaluation for under 
\$100 in compute [46-48].
* **`CLAUDE.md` / `AGENTS.md` Context Files**: Root-level project specifications
containing architecture, build commands, and behavioral constraints [49-51].
* **OpenClaw & Text-as-Installer**: Plain-text runbooks copied into agents to 
parse machine environments and install software natively [13, 15, 17].

#### Top Do's and Don'ts

| Category | Do's | Don'ts |
| :--- | :--- | :--- |
| **Mindset** | **DO** treat the context window as your program and the LLM as 
the interpreter (`Software 3.0`) [52-54]. | **DON'T** anthropomorphize LLMs. 
They are *"statistical simulation circuits / ghosts"*, not animals—yelling at 
them does not improve output [37, 55-58]. |
| **Architecture** | **DO** write detailed `SPEC.md` and `CLAUDE.md` files 
before generating code [7, 10, 12, 50]. | **DON'T** build complex middle-tier 
plumbing when direct vision/diffusion model prompts can transform inputs 
natively (e.g., *MenuGen* vs. *Nano Banana*) [13, 59, 60]. |
| **Execution** | **DO** follow the **Surgical Changes** rule: touch only 
requested lines, match repo style, and clean up orphaned variables/imports [12, 
61, 62]. | **DON'T** let agents overcomplicate code, introduce speculative 
single-use abstractions, or refactor unbroken adjacent code [12, 61, 62]. |
| **Knowledge** | **DO** delegate API syntax recall (e.g., PyTorch `keepdim` vs 
`keep_dims`, `dim` vs `axis`, `reshape` vs `permute`) to agents [4, 8, 63, 64]. 
| **DON'T** outsource structural understanding—humans must retain deep mental 
models of tensor storage, invariants, security, and identity [4, 8, 63, 65, 66].
|

> *Karpathy's Golden Rule:* **"You can outsource your thinking, but you can't 
outsource your understanding."** [4, 63, 65-67]

---

💡 **Would you like me to help turn Karpathy's 4 Rules into a tailored 
`CLAUDE.md` file or an evaluation test harness for one of your projects?**

Conversation: 0fac7947-b3f4-4d6f-9b19-3fa4afaab1eb (turn 3)
