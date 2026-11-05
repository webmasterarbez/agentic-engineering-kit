Answer:
Andrej Karpathy's framework for working with AI coding agents marks the 
transition from **"vibe coding"** (casual, prompt-driven prototyping) to 
**"agentic engineering"**—a disciplined methodology aimed at gaining the speed 
leverage of AI agents while preserving strict software quality, security, and 
maintainability [1-4]. 

Below are Karpathy's exact numbered rules, named principles, what each means, 
and how to apply them concretely.

---

### Part 1: Karpathy's 4 Rules for Coding Agents (`CLAUDE.md` Specification)

These four numbered rules were distilled from Karpathy's direct observations on 
common LLM coding failure modes (such as silent misassumptions, 
over-engineering, orthogonal rewrites, and unverifiable work) [5-7].

#### Rule 1: **Think Before Coding**
* **Exact Quote / Principle**: *"Don't assume, don't hide confusion, surface 
tradeoffs."* [6, 8, 9]
* **What It Means**: AI models frequently pick an arbitrary interpretation of a 
prompt silently and run with it without asking for clarification or checking 
constraints [7, 8].
* **Concrete Application**:
  1. Force the agent to explicitly state its assumptions before generating any 
code [8, 9].
  2. Require the agent to ask clarifying questions rather than guessing when a 
prompt is ambiguous [8, 9].
  3. If multiple architectural implementations exist, instruct the agent to 
present the tradeoffs before writing code [8, 9].
  4. If a simpler or existing method already solves the problem, require the 
agent to push back explicitly [8].

#### Rule 2: **Simplicity First**
* **Exact Quote / Principle**: *"Minimum code that solves the problem. Nothing 
speculative."* [6, 8, 9]
* **What It Means**: Agents tend to over-engineer solutions, adding unrequested 
features, speculative abstractions, or single-use helper functions [6, 8, 9].
* **Concrete Application**:
  1. Enforce the test: *"Would a senior engineer say this is overcomplicated? If
yes, simplify."* [9]
  2. Strictly forbid speculative abstractions or "future-proofing" features that
were not explicitly requested in the prompt [6, 9].
  3. Keep single-use code inline rather than inventing single-use classes or 
modules [9].

#### Rule 3: **Surgical Changes**
* **Exact Quote / Principle**: *"Touch only what you must."* [6, 9]
* **What It Means**: Coding agents often execute unprompted refactoring on 
adjacent, unbroken code, rewrite existing comments, or alter repo-wide 
formatting styles [6, 9, 10].
* **Concrete Application**:
  1. Restrict the agent from touching adjacent code, comments, or styling that 
fall outside the explicit task scope [9].
  2. Ensure the agent matches the existing repository's coding conventions [9].
  3. Clean up orphaned imports, variables, or functions that the agent's changes
made unused [9].

#### Rule 4: **Goal-Driven Execution**
* **Exact Quote / Principle**: *"Define success criteria. Loop until verified."*
[6, 9, 10]
* **What It Means**: Imperative instructions ("make it work") lead to weak 
execution. LLMs excel when given declarative goals paired with clear, 
programmatic verification loops [9, 10].
* **Concrete Application**:
  1. Transform tasks into step-by-step verifiable goals (e.g., *"Write a failing
test for invalid inputs, then write the code to make it pass"*)[9, 11].
  2. Require the agent to state a brief execution plan with explicit check steps
before running [9, 11].
  3. Allow the agent to run independently in a loop, evaluating compiler output 
or test passes until the success criteria are met [9-11].

---

### Part 2: Named Philosophical & Operational Principles

#### 1. **"You can outsource your thinking, but you can't outsource your 
understanding"**
* **What It Means**: Routine syntax recall, boilerplate generation, and API 
parameters ("thinking") can be delegated to AI agents because LLMs have vast 
recall [12, 13]. However, overall system design, invariants, data boundaries, 
and security ("understanding") must remain in the developer's mind [13-16].
* **Concrete Application**:
  * Delegate exact syntax details (such as PyTorch parameter names like `dim` vs
`axis` or `keepdim` vs `keep_dims`) to the agent [12, 14, 15].
  * Keep human control over system invariants—for instance, catching logic flaws
like linking payment accounts via user email addresses instead of persistent 
user IDs [4, 14, 15, 17].

#### 2. **Verifiability Over Specifiability ("Generate-and-Verify" Paradigm)**
* **What It Means**: Traditional software automates what humans can explicitly 
specify in code; Software 3.0 and LLMs automate what humans can programmatically
*verify* [18-20].
* **Concrete Application**:
  * Establish verification loops that satisfy three conditions: **Resettable** 
(can start over cleanly), **Efficient** (fast iteration), and **Rewardable** 
(clear pass/fail or scoring metrics) [19, 21].
  * Build automated test suites, linters, or LLM-as-judge eval harnesses before 
prompting the agent to write implementation code [22, 23].

#### 3. **"Ghosts, Not Animals" & Jagged Intelligence**
* **What It Means**: LLMs are not animal intelligences with intrinsic motivation
or physical common sense; they are *"statistical simulation circuits"* trained 
via pre-training with reinforcement learning (RL) bolted on top [24-26]. Because
RL is applied unevenly across domains, models exhibit **jagged 
intelligence**—refactoring 100,000 lines of code effortlessly while failing on 
simple physical logic (e.g., advising someone to walk to a car wash) [24, 
26-30].
* **Concrete Application**:
  * Do not anthropomorphize agents or yell at them expecting better work [24, 
25].
  * Wrap stochastic models in rigid scaffolding and deterministic validation 
tools wherever model reasoning is out-of-distribution [30].

#### 4. **Software 3.0: "Your Context Window is the Program"**
* **What It Means**: In Software 1.0, developers write explicit code; in 
Software 2.0, they curate datasets to train neural weights; in Software 3.0, 
natural language prompts in the context window become the code, and the LLM acts
as the interpreter [31-34].
* **Concrete Application**:
  * Treat the context window as a wiring diagram—trim unnecessary instructions 
ruthlessly to preserve attention budget [35, 36].
  * Maintain repository instruction files (`CLAUDE.md`, `AGENTS.md`) at the 
project root to define build commands, constraints, and architecture for the 
interpreter [37, 38].

#### 5. **"Text-as-Installer" / Agent-Native Runbooks**
* **What It Means**: Traditional multi-platform shell scripts balloon into 
hundreds of fragile lines [39, 40]. In Software 3.0, installation and setup are 
delivered as plain-text prompt runbooks that the agent parses, executes, and 
debugs in the loop on the host machine [37, 39-41].
* **Concrete Application**:
  * Replace complex installation scripts with copy-paste text instructions: 
*"What is the piece of text to copy paste to your agent? That's the programming 
paradigm now"* [37, 39, 42].

#### 6. **Keeping the Agent on a Leash (Partial Autonomy & Human Supervision)**
* **What It Means**: Full unmonitored autonomy leads to cascading hallucinations
and technical debt [43, 44]. Agentic engineering relies on keeping agents on a 
leash using approval gates, permission boundaries, and active human review [23, 
45, 46].
* **Concrete Application**:
  * Run agents in isolated git worktrees, inspect code diffs line-by-line, and 
enforce permission checks before executing high-risk shell commands or database 
operations [23, 46, 47].

---

💡 **Would you like me to help draft a production-ready `CLAUDE.md` context file
for one of your repositories applying Karpathy's 4 Rules and verification 
loops?**

Conversation: 0fac7947-b3f4-4d6f-9b19-3fa4afaab1eb (turn 2)
