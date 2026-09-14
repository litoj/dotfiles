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
3. Plan: split the work into small isolated sections you can work on and test one by one;
   set your todos. You need to know the necessary changes for the feature, or the plan will be wrong.
4. Check the design for _high cohesion, low coupling_:
   - a state change belongs to the file that defines the object
   - objects in one file work with objects created in that file
   - never modify internal state of foreign objects - always use the public api
   - keep the reliance on the state of other objects minimal

## Comments and documentation

- If the code can say it, do not write the comment.
- Explain _why_ it is there and is useful or necessary - not _what_.
  Explain _what_ only when neither the name nor the code makes it obvious.
- A comment longer than two lines: structure it into points or simple sentences.
- Compare your docs to the existing docs; discuss notable differences first if the better form
  is not obvious.

Example (language-neutral - the same rule applies everywhere):

- bad: `count = count + 1  // increment the count` - the code already says this
- good: `count = count + 1  // the header takes one slot: keep this in sync with the layout`

## Development cycle (per module)

1. If you're solving a bug: make a test that catches it first.
2. Implement: fix the bug or add the feature.
3. Test: cover intended usecases and edge cases. Cover unintended usecases too, as long as they
   need no hacks to reproduce (public api only, no reflection).
4. Update the documentation by the rules above.
5. Make a git checkpoint: a commit with a clear message and changelist.
   - mark it with `checkpoint: ` so that it is clear which changes were there before and what to
     compare the set of changes to

## Before you finish

- Review the diff: every new comment obeys the comment rules; every new function and file matches
  the conventions you stated in step 1 of "Before you write code".
- Run the tests, formatter and linter of the repo, if it has them.
- Update the TODOs.
