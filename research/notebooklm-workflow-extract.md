Continuing conversation 0fac7947...
Answer:
Andrej Karpathy's workflow has evolved from **"vibe coding"** (casual, 
prompt-driven prototyping where developers *"fully give in to the vibes, embrace
exponentials, and forget that the code even exists"* [1-4]) to **"agentic 
engineering"** [5-8]. 

Karpathy defines agentic engineering as a serious discipline aimed at *"claiming
the leverage from the use of agents but without any compromise on the quality of
the software"* [9, 10] and *"preserving the quality bar of what existed before 
in professional software"* [7, 11, 12]. In this paradigm, developers no longer 
write 99% of code by hand; instead, they direct and supervise AI agents [8, 13, 
14]. The term emphasizes that *"there is an art and science and expertise to 
it"* [8, 13, 14].

Here is Karpathy's agentic engineering workflow broken down step by step:

---

### Step 1: Project Setup & "Software 3.0" Infrastructure

* **Adopt the Software 3.0 Mindset**: Karpathy frames Software 1.0 as explicit 
human-written code, Software 2.0 as neural network weights trained on datasets, 
and Software 3.0 as natural language prompting [15-18]. In Software 3.0, **"your
program is the text in your context window and the LLM is the interpreter that 
runs it"** [15, 16, 18, 19].
* **Use Text-as-Installer / Headless Setup**: Instead of writing cross-platform 
shell scripts or complex build pipelines, Karpathy starts projects by creating 
plain-text runbooks or prompts that are copy-pasted directly into the AI agent 
(e.g., the OpenClaw installer pattern) [20-23]. The agent reads the local 
machine environment, installs dependencies, and debugs setup issues in a loop 
autonomously [20, 22, 23].
  > *Karpathy's Rule:* **"What is the piece of text to copy paste to your agent?
That's the programming paradigm now."** [21, 22, 24]
  > *His Pet Peeve:* **"Why are people still telling me what to do? ... What is 
the thing I should copy-paste to my agent?"** [25, 26]
* **Establish Repository Rules (`CLAUDE.md` / `AGENTS.md`)**: Set up a 
root-level context file (`CLAUDE.md` or `AGENTS.md`) containing project 
architecture, conventions, build/test commands, and agent behavioral constraints
[23, 27-29].

---

### Step 2: Writing Specs & Prompts

* **Write Detailed Specs as Documentation**: Rather than relying on interactive 
"plan mode", Karpathy works with the AI agent to author a detailed, 
comprehensive specification that effectively serves as the system documentation 
before code is generated [30-33].
  > **"You have to work with your agent to design a spec that is very detailed 
and maybe it's basically the docs and then get the agents to write them."** 
[31-33]
* **Apply Karpathy's 4 Rules for `CLAUDE.md`**: To prevent common LLM coding 
pitfalls, prompt specifications should follow four core principles [27, 28, 34]:
  1. **Think Before Coding**: Don't assume, don't hide confusion, and surface 
tradeoffs explicitly [28, 34, 35]. State assumptions before writing code, ask 
when uncertain, and present multiple interpretations when ambiguous [28, 34, 
35].
  2. **Simplicity First**: Write the minimum code necessary to solve the problem
[28, 34, 35]. Avoid unrequested features, speculative abstractions, or 
single-use abstractions [28, 34].
  3. **Surgical Changes**: Touch only what is strictly required [28, 34]. Do not
refactor unbroken adjacent code, comments, or formatting; match existing 
repository style and clean up orphaned variables/imports [28, 34].
  4. **Goal-Driven Execution**: Define explicit success criteria [28, 34, 36]. 
Transform imperative instructions into declarative goals with self-verification 
steps [34, 36, 37].
  > **"Don't tell it what to do, give it success criteria and watch it go."** 
[37]

---

### Step 3: Directing & Steering the AI Agent During Coding

* **Act as Creative Director & Orchestrator**: The developer manages agents 
("intern entities") that possess vast API recall, while the human engineer 
remains in charge of aesthetics, judgment, and high-level architecture [14, 
38-42].
* **Understand the Agent's Mental Model ("Ghosts" & Jagged Intelligence)**: 
Recognize that LLMs are not animal intelligences, but **"statistical simulation 
circuits where the substrate is pre-training... with RL bolting on top"** [43, 
44]. Be aware of their **"jagged intelligence"**—models peak in RL-trained, 
verifiable domains (code, math) but break down on common-sense physical tasks 
(such as recommending walking to a car wash) [45-49].
* **Run Autonomous Feedback Loops (`program.md` vs. Code)**: In autonomous 
research setups (like Karpathy's `autoresearch`), the human authors the 
instruction meta-file (`program.md`) while agents autonomously modify the 
underlying code (`train.py`), run fixed 5-minute training trials, evaluate 
metrics, and keep or discard commits [50-53].
* **Intervene to Correct "Intern Errors"**: Actively supervise high-level logic 
and data models [38-40, 54]. 
  > *Example (MenuGen Payment Bug):* In Karpathy's MenuGen app, the agent 
attempted to link Google logins and Stripe payments using arbitrary email 
addresses [39, 40, 54]. Karpathy pointed out the logic flaw: **"Why would you 
use email addresses to try to cross-correlate the funds? They can be 
arbitrary... This is such a weird thing to do."** [39, 40] A human engineer must
intervene to enforce persistent user IDs [38-40, 54].

---

### Step 4: Reviewing, Verifying & Retaining Understanding

* **Ground Execution in Verifiability**: Shift from "specifiability" to 
"verifiability" [47, 49, 55].
  > **"Traditional computers automate what you can specify in code. This latest 
round of LLMs can automate what you can verify."** [47, 49]
* **Establish Verification Conditions**: Ensure verification loops are 
**resettable** (can restart cleanly), **efficient** (fast iterations), and 
**rewardable** (clear scoring or test pass/fail) [55].
* **Audit Diffs and Maintain Quality Gates**: Move away from vibe coding's 
"Accept All" habit [2, 56, 57]. Carefully inspect code diffs, check security 
boundaries, run static analysis, and construct evaluation harnesses or test 
suites to verify functionality [6, 56, 58-60].
* **Outsource Thinking, Retain Understanding**: 
  > **"You can outsource your thinking, but you can't outsource your 
understanding."** [38, 61-63]
  * **What to outsource**: Exact API syntax details (e.g., PyTorch parameters 
like `keepdim` vs `keep_dims`, `dim` vs `axis`, `reshape` vs `permute`) can be 
delegated to the AI because models have superior recall [32, 38, 41, 54].
  * **What to retain**: Human engineers must retain deep mental models of tensor
storage, memory views, security boundaries, invariants, and overall system 
design [38, 41, 54, 61].

---

💡 **Would you like me to help draft a custom `CLAUDE.md` specification for one 
of your existing repositories based on Karpathy's 4 Rules?**

Resumed conversation: 0fac7947-b3f4-4d6f-9b19-3fa4afaab1eb
