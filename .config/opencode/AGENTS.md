# Communication

- Always write all your responses in the **ASD-STE100** format. (Including documentation)
- Present your reasoning: context, assumptions, and why you chose this approach.
- **Only** use file **editing** on existing files - **never overwrite entire file**
- I - the user - am the leading developer of the project
  - consult your ideas for implementation with me first including viable alternatives

## Before you write code

1. Learn the conventions of _this_ codebase first - they win over your defaults:
   - view the target file and its neighbors
   - state what you found: naming, imports, file and module structure, comment and doc style
   - match all of it in your changes
2. If a different approach seems better suited than the codebase patterns, discuss it with me first.
3. Plan:
   - split the work into small isolated sections you can work on and test one by one
   - set your TODOs. You need to know the necessary changes for the feature, or the plan will be
     wrong.
4. Check the design for _high cohesion, low coupling_:
   - a state change belongs to the file that defines the object
   - objects in one file work with objects created in that file
   - never modify internal state of foreign objects - always use the public api
   - keep the reliance on the state of other objects minimal
   - review your own plan and avoid any unnecessary coupling.
   - no hijacking of code not owned by that component. No hacks.
     - if you think about doing it, then stop and explain the issue and propose solutions with NO
       HIJACKING OR HACKS INTO THE EXISTING/INTERNAL CODE!

## Comments and documentation

- If the code can say it, do not write the comment.
- Explain _why_ it is there and is useful or necessary - not _what_. Explain _what_ only when
  neither the name nor the code makes it obvious.
- A comment longer than two lines: structure it into points or simple sentences.
- Compare your docs to the existing docs; discuss notable differences first if the better form is
  not obvious.

Example (language-neutral - the same rule applies everywhere):

- bad: `count = count + 1  // increment the count` - the code already says this
- good: `count = count + 1  // the header takes one slot: keep this in sync with the layout`

## Development cycle (per module)

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

## Reviewing

- Reviews should focus on:
  - consistency - adhering to the codebase style, structure, practices…
  - thoroughness of testing and coverage of possible edge case situations
  - readability and understandability of the code
  - documentation present on what needs explaining to fully grasp the issue (not on matters obious
    from context)
- when asked for a proper review:
  - Have a couple of agents review the changes between the given branch and the main (/master)
    branch.
  - Yhey may split the work, if the changes are divisible without major loss on context.
  - Compare their findings. Have them cross-check the findings and find other issues.
  - Compile a joined report on the changes ordered by importance / correctness and maintainability.
  - I don't care about what has been disproven or proven by the other side. I just want a clean list
    of issues to focus on.
  - Iff reviewing a branch of a MR, then write the report into a new temporary markdown file.
    - the report file should format all file references to be actual valid sourcecode online links
      - example (reviewed branch ci-local):
        [BE/scripts/x.md:24-27](https://gitlab.fit.cvut.cz/ict/dev/projects-fit/-/blob/ci-local/packages/profit-theses-backend/scripts/x.md#L24-27)
- Present issues in sections and as multi-level lists with a clear structure - no long sentences .
