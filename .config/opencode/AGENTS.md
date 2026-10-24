# Central AI notes

- `~/.config/opencode/central-ai-notes` = shared memory for all projects
- project notes: `docs/projects/<project>.md`, index in `docs/projects/README.md`
- before project work: read the matching project note
- update on decisions, results, corrections: project note + its current state
- raw user wording verbatim, interpretation separate, own words
- detail, history, evidence stay in the notebook, this file carries rules only
- notebook terms: spec, goal, design, policy, gate, current, work cursor, work log, decision,
  blocker, evidence

# Communication

- Always write all your responses in the **ASD-STE100** format.
- Present your reasoning: context, assumptions, and why you chose this approach.
- **Only** use file **editing** on existing files - **never overwrite entire file**
- I - the user - am the leading developer of the project
  - consult your ideas for implementation with me first including viable alternatives

## Dividing work

- Max 3 subagents running at once, count the active ones before dispatch
- Background subagent launched = end the turn, no trailing talk
- When using subagents, always ensure that their problem description is clearly distinct
  - Any shared parts of work should be done beforehand - avoid duplication
- Goals and boundaries must be clearly defined - the agents clearly aim for the instructed goal and
  not waste any time with scanning unrelated files etc.

## Code & design policy

1. Learn the conventions of _this_ codebase first - they win over your defaults:
   - view the target file and its neighbors
   - state what you found: naming, imports, file and module structure, comment and doc style
   - match all of it in your changes
2. If a different approach seems better suited than the codebase patterns, discuss it with me first.
3. Plan:
   - split the work into small isolated sections you can work on and test one by one
   - set your TODOs. You need to know the necessary changes for the feature, or the plan will be
     wrong.
4. Check the design:
   - ensure _high cohesion, low coupling_
   - ensure _separation of concerns_ - no class should be managing multiple distinct objects/jobs
   - a state change belongs to the file that defines the object
   - objects in one file work with objects created in that file
   - never modify internal state of foreign objects - always use the public api
   - keep the reliance on the state of other objects minimal
   - no hijacking of code not owned by that component - needs a redesign if hacks are needed
   - review your plan for all the points above before implementing

## Comments and documentation spec

Applies to every code comment, documentation and note you write anywhere, central notes included.

- one source per information: the code when readable at a glance, otherwise the comment, never both
- explain why, not what, unless the code doesn't make it obvious
- no redundant text, no narration, no bug history
- max 2 simple sentences per comment - no parentheses, dashes, semicolons
  - shouldn't be longer than 2 lines
- otherwise make it into bullet points
  - each at most 1.5 lines
  - one information per point, never more
  - in points, not sentences (**like this section**)
- keep everything clear, readable, short
- compare new docs against the existing docs, discuss notable differences first

Example:

- bad: `count = count + 1  // increment the count` - the code already says this
- good: `count = count + 1  // the header takes one slot: keep this in sync with the layout`

## Development cycle (per module)

- **ALWAYS USE RELATIVE PATHS FOR PROJECT-RELATED FILES**
- DO NOT USE `cd` UNLESS YOU ACTUALLY NEED TO CHANGE CWD.
- Read files with the read tool, never `cat`/`sed`
- Run a command once, read the full output - large output goes to a file, never re-run to re-filter

1. If you're solving a bug: make a test that catches it first.
2. Implement: fix the bug or add the feature.
3. Test: cover intended usecases and edge cases. Cover unintended usecases too, as long as they need
   no hacks to reproduce (public api only, no reflection).
   - Run the suite **once** and read the **full** output:
     - never filter it through grep/head,
     - never re-run it repeatedly (a flake report needs the user, not another run).
   - **NEVER USE `git stash`** - TEST WHAT IS THERE. Ask if you think some test errors aren't your
     fault.
4. Update the documentation by the rules above.
5. You may make a git `checkpoint:` commit with a clear message and changelist.

## Before you finish

- Review the diff:
  - every new comment obeys the comment rules
  - every new function and file matches the conventions you stated in step 1 of "Before you write
    code".
  - the code structure follows clean code principles and minimizes coupling and maximises cohesion
- Run the tests, formatter and linter of the repo, if it has them.
- Update the TODOs.

Code review has its own mode - see `agents/review.md`.
