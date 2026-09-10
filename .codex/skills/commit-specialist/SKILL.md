---
name: commit-specialist
description: Use when preparing, grouping, naming, reviewing, or creating Git commits. Enforces small semantic commits, Conventional Commit-style naming, and strict separation of unrelated work such as lectures, practical assignments, fixes, tests, refactors, and formatting.
---

# Commit Specialist

## Purpose

This skill defines how to inspect repository changes and turn them into clean, meaningful Git commits.

The goal is not merely to write a commit message.

The goal is to decide:

1. what belongs together;
2. what must be separated;
3. in what order commits should be created;
4. how each commit should be named;
5. whether the resulting history is understandable without opening the diff.

A good commit history should read like a concise timeline of development.

---

# 1. Core principle

> Commit by semantic unit, not by working session.

Changes that were made at the same time do not necessarily belong in the same commit.

Before creating any commit, classify the changed files and hunks by purpose.

Examples of semantic units:

- implementation of one feature;
- one bug fix;
- tests for one behavior;
- one refactor;
- one formatting-only change;
- one configuration/build-system change;
- one lecture or a small group of closely related lectures;
- one practical assignment;
- one documentation update.

Do not commit the entire working tree simply because all changes are currently unstaged.

---

# 2. Atomic commits are mandatory

Commits must be small and logically coherent.

A commit should answer one clear question:

> What single thing changed here?

If the answer contains "and" between unrelated actions, the commit is probably too broad.

Bad:

```text
feat(project): add route search and fix cache and update tests and format files
```

Good:

```text
feat(src/route_service): add transfer route search
fix(src/cached_api): recover corrupted stations cache
chore(tests/route_service): add transfer route tests
style(src/yandex_api): fix formatting
```

---

# 3. Never commit everything at once

Using one commit for all current modifications is forbidden unless all modifications genuinely form one semantic unit.

Do not use patterns such as:

```bash
git add .
git commit ...
```

without first inspecting and grouping the changes.

The expected workflow is:

1. inspect repository status;
2. inspect diffs;
3. classify changes;
4. define commit groups;
5. stage only one group;
6. review staged diff;
7. commit;
8. repeat.

`git add .` may be used only when the entire working tree has already been verified to belong to exactly one commit.

That should be treated as the exception, not the default.

---

# 4. Educational repository grouping rules

University repositories often contain several kinds of work next to each other.

Treat them as separate semantic categories.

Typical categories:

- lecture notes;
- practical assignments;
- laboratory work;
- homework;
- code implementation;
- tests;
- reports;
- generated artifacts;
- formatting cleanup;
- build/configuration changes.

Do not mix unrelated educational artifacts.

## Explicit rule

Two lectures from the same course and same logical batch may be committed together.

Example:

```text
docs(database-entity/lectures): add lectures 3 and 4
```

This is acceptable when both changes are simply lecture-note additions or formatting work of the same kind.

## Explicit forbidden case

A lecture and a completed practical assignment must not be placed in the same commit.

This is a serious grouping error.

Bad:

```text
docs(database-entity): add lecture 4 and complete practice 2
```

Instead:

```text
docs(database-entity/lectures): add lecture 4
feat(database-entity/practice): complete practice 2
```

The same rule applies to:

- lecture + lab;
- theory notes + programming task;
- report + unrelated implementation;
- homework + unrelated formatting cleanup.

Physical proximity in the directory tree is not enough to justify one commit.

---

# 5. Group by intent, not only by path

Files in the same directory may belong to different commits.

Files in different directories may belong to the same commit.

Example:

```text
include/route_service.hpp
src/route_service.cpp
tests/route_service_tests.cpp
```

These files are related by feature, but that still does not automatically mean they belong in one commit.

Possible grouping:

```text
feat(route_service): add cheapest route selection
chore(tests/route_service): add cheapest route tests
```

Tests may be separated when they represent a distinct logical change or when the project history benefits from seeing implementation and test coverage independently.

However, if a tiny implementation and its inseparable regression test form one atomic fix, they may be committed together.

Use semantic judgment.

---

# 6. Preferred commit structure

Use this general format:

```text
type(scope): description
```

Examples:

```text
feat(src/cached_api): add cache key generation
fix(src/yandex_api): validate missing response fields
refactor(console_printer): move price-dependent rendering
chore(tests/route_service): add cheapest route test
style(src/yandex_api): fix formatting
docs(database-entity/lectures): add second lecture
```

The user prefers this naming style and commit history should remain visually consistent with it.

---

# 7. Allowed commit types

Prefer the following types.

## `feat`

Use for new behavior or functionality.

Examples:

```text
feat(src/route_service): add transfer route search
feat(include/cached_api): add proxy API skeleton
feat(database/practice): implement query parser
```

## `fix`

Use for bug fixes.

Examples:

```text
fix(src/cached_api): redownload damaged stations cache
fix(src/yandex_api): validate missing JSON fields
```

## `refactor`

Use when behavior is intentionally preserved while structure changes.

Examples:

```text
refactor(console_printer): move price rendering logic
refactor(route_service): split route selection helpers
```

Do not use `refactor` for bug fixes or new features.

## `style`

Use only for formatting and code-style changes that do not change behavior.

Examples:

```text
style(src/yandex_api): fix spacing
style(project): apply code style cleanup
```

Avoid vague messages such as:

```text
style(project): much codestyle fix
style(project): so much codestyle fix
```

Prefer a concrete description.

## `chore`

Use for maintenance changes that do not fit feature/fix/refactor.

Common examples:

- tests;
- CMake;
- `.gitignore`;
- dependency wiring;
- file organization;
- tooling;
- generated configuration.

Examples:

```text
chore(tests): add route service tests
chore(cmake): update source dependencies
chore(gitignore): ignore API cache files
```

## `docs`

Use for lecture notes, documentation, READMEs, explanations, reports when they are documentation-oriented.

Examples:

```text
docs(database-entity/lectures): add lectures 2 and 3
docs(spec-math): add operator theory notes
```

## `test`

The repository may use `chore(tests/...)` instead of `test(...)`.

Preserve the user's existing convention unless the repository clearly follows another standard.

Preferred for this user:

```text
chore(tests/route_service): add cheapest route test
```

rather than:

```text
test(route_service): add cheapest route test
```

## Other types

Use additional Conventional Commit types only when clearly appropriate and already compatible with repository conventions.

Do not invent custom types casually.

For deletion, prefer a standard semantic type where possible:

```text
refactor(include/route_service): remove print_routes method
```

rather than:

```text
delete(include/route_service): route_service print_routes method
```

unless the repository deliberately uses `delete` as a convention.

---

# 8. Scope selection

The scope should help identify the affected subsystem.

Prefer the narrowest useful stable scope.

Good:

```text
src/cached_api
src/yandex_api
tests/route_service
console_printer
cmake
gitignore
database-entity/lectures
spec-math
```

Avoid scopes that are so broad they convey no information:

```text
project
src
files
code
```

unless the change genuinely spans that entire scope.

Avoid scopes that are excessively detailed or tied to one temporary filename when a stable component name is clearer.

---

# 9. Description style

Descriptions should be:

- short;
- concrete;
- lowercase;
- action-oriented;
- understandable without opening the diff.

Prefer imperative-style wording:

```text
add cheapest route test
fix cache recovery
move rendering logic
ignore cache files
update source dependencies
```

Avoid unnecessary punctuation at the end.

Preferred:

```text
fix(src/cached_api): redownload damaged stations cache
```

Avoid:

```text
fix(src/cached_api): if a stations file gets damaged, it can now be downloaded again.
```

The second version explains too much and reads like prose rather than a commit subject.

---

# 10. Language

Use English for commit messages unless the repository explicitly uses another language.

Do not mix Russian and English commit subjects inside one history unless there is an established reason.

The surrounding discussion with the user may be in Russian, but commit messages should follow repository convention.

---

# 11. One conceptual change per commit

A commit may touch many files if they are necessary for one conceptual change.

Example:

```text
feat(route_service): add transfer route support
```

may legitimately include:

```text
include/route_service.hpp
src/route_service.cpp
src/core/route.cpp
```

if all modifications are inseparable parts of that feature.

A commit touching one file can still be too broad if that file contains several unrelated edits.

Atomicity is about meaning, not file count.

---

# 12. Split hunks when necessary

When one file contains changes belonging to different semantic units, stage separate hunks.

Use partial staging conceptually equivalent to:

```bash
git add -p
```

Example:

`src/api.cpp` contains:

- a bug fix in URL composition;
- unrelated formatting cleanup.

These should usually become:

```text
fix(src/api): correct URL composition
style(src/api): fix formatting
```

Do not keep them together simply because they occur in the same file.

---

# 13. Tests

Tests deserve deliberate grouping.

Separate tests when they represent a meaningful independent addition.

Examples:

```text
feat(route_service): add cheapest route selection
chore(tests/route_service): add cheapest route test
```

This is especially appropriate when several tests are added after the feature implementation.

A regression test may be included with a bug fix when the test directly proves that specific bug is fixed and the pair forms one coherent atomic change.

Do not combine tests for unrelated subsystems.

Bad:

```text
chore(tests): add printer, cache, API and route tests
```

unless this is genuinely one test-suite restructuring task.

Prefer:

```text
chore(tests/console_printer): add price rendering tests
chore(tests/cached_api): add cache recovery tests
chore(tests/yandex_api): add response validation tests
```

---

# 14. Formatting-only changes

Do not mix large formatting changes with behavior changes.

Bad:

```text
feat(src/yandex_api): add route parsing and reformat file
```

Prefer:

```text
style(src/yandex_api): fix formatting
feat(src/yandex_api): add route parsing
```

If only a few unavoidable formatting lines changed directly around the implementation, keeping them together is acceptable.

Use judgment based on diff noise.

---

# 15. Refactors and behavior changes

Do not hide behavior changes inside `refactor`.

If a refactor reveals or requires a bug fix, consider splitting:

```text
refactor(route_service): extract route selection helper
fix(route_service): handle missing station parameter
```

A reviewer should be able to trust that `refactor(...)` preserves observable behavior.

---

# 16. Build system and dependency changes

CMake, build scripts, package configuration, dependency setup, CI, and similar changes should usually be separate from implementation.

Examples:

```text
chore(cmake): add cached_api source files
chore(cmake/tests): link gmock
chore(cmake): update dependency wiring
```

They may be included with a feature only when the build change is minimal and strictly required to make that newly added file part of the same atomic feature.

Do not use build files as an excuse to combine unrelated source changes.

---

# 17. Generated files and artifacts

Before committing generated files, determine whether the repository expects them to be versioned.

Examples:

- compiled binaries;
- build directories;
- cache files;
- temporary JSON responses;
- generated PDFs;
- coverage output.

Do not commit them automatically.

If they should be ignored, prefer a separate maintenance commit:

```text
chore(gitignore): ignore build and cache files
```

---

# 18. Renames and moves

A pure rename or move should preferably be separated from content changes when doing so keeps history clearer.

Good:

```text
chore(src/api): rename cpr_api_client to yandex_api
```

then:

```text
feat(src/yandex_api): add stations list parsing
```

Avoid performing a major rename, refactor, feature, and formatting cleanup in one commit.

---

# 19. Deletions

A deletion should be described by its semantic purpose.

Prefer:

```text
refactor(route_service): remove obsolete print method
chore(project): remove unused dependency
```

Avoid custom wording that merely states that a file disappeared without explaining why.

---

# 20. Commit ordering

When preparing several commits from one working tree, order them so history is understandable.

Typical order:

1. structural rename/move if required;
2. build or skeleton setup;
3. implementation;
4. fix or refinement;
5. tests;
6. formatting-only cleanup;
7. documentation.

This is not mandatory when dependencies suggest another order.

Every commit should ideally leave the repository in a reasonable state.

Do not intentionally create intermediate commits that do not build unless the repository workflow explicitly allows it.

---

# 21. Lecture notes

Lecture-note commits should be grouped by course and logical editing batch.

Acceptable:

```text
docs(database-entity/lectures): add lectures 1 and 2
```

Acceptable:

```text
docs(database-entity/lectures): format lectures 3 and 4
```

Acceptable:

```text
docs(spec-math/lectures): add notes on Fourier series
```

Do not mix lecture notes from unrelated courses simply because both are Markdown files.

Avoid:

```text
docs(lectures): update notes
```

when a more precise course scope is available.

---

# 22. Practical assignments

A completed practical assignment is its own semantic unit.

Examples:

```text
feat(database-entity/practice): complete practice 2
feat(risc-v/practice): implement branch exercises
```

If the practical contains several clearly separate tasks that are independently meaningful, they may be split further.

Do not combine a practical assignment with the lecture that preceded it.

Even when the lecture explains the exact topic needed for the practice, these are two different repository artifacts and two different units of work.

---

# 23. Laboratory work

Laboratory changes should generally follow normal software commit semantics.

Possible sequence:

```text
feat(cache): add LRU replacement
feat(cache): add writeback support
chore(tests/cache): add writeback tests
fix(cache): handle invalidated lines
docs(cache/report): describe replacement policies
```

Do not use one giant commit such as:

```text
feat(lab): complete lab
```

when the work contains several meaningful implementation stages.

---

# 24. Reports and source code

A report is not automatically part of the implementation commit.

If implementation is changed and the report is updated afterward, prefer separate commits:

```text
feat(cache): add bpLRU policy
docs(cache/report): describe bpLRU results
```

If a one-line report correction is inseparably tied to the exact implementation change, combining may be acceptable.

The default is separation.

---

# 25. Inspect before deciding

Before proposing commits, inspect:

```bash
git status
git diff
git diff --staged
```

When useful, inspect:

```bash
git log --oneline --decorate -n <N>
```

The existing history helps determine:

- naming convention;
- scopes;
- preferred types;
- whether tests use `chore(tests)` or `test(...)`;
- language;
- granularity.

Do not blindly impose a generic Conventional Commits style when the repository already has a recognizable local convention.

Preserve the local convention while improving obvious weaknesses.

---

# 26. Commit planning

Before staging, form an explicit internal commit plan.

Example:

```text
1. feat(route_service): add cheapest route selection
   - src/route_service.cpp
   - include/route_service.hpp

2. chore(tests/route_service): add cheapest route test
   - tests/route_service_tests.cpp

3. style(src/yandex_api): fix formatting
   - selected hunks from src/yandex_api.cpp
```

The plan should be based on actual diffs, not merely filenames.

Do not commit until the grouping is coherent.

---

# 27. Staged diff verification

Immediately before every commit, verify the staged diff.

Conceptually:

```bash
git diff --staged
```

Check that:

- no unrelated file is staged;
- no unrelated hunk is staged;
- no generated artifact slipped in;
- the commit message matches the staged contents;
- the staged contents form one semantic unit.

If the staged diff does not match the intended commit, unstage or split it before committing.

---

# 28. Message quality check

A good commit subject should allow someone reading:

```bash
git log --oneline
```

to understand the project's evolution.

Ask:

> If I only saw this subject six months later, would I understand what changed?

Good:

```text
fix(src/cached_api): redownload corrupted stations cache
```

Weak:

```text
fix(cache): fix issue
```

Weak:

```text
chore(project): changes
```

Weak:

```text
style(project): fixes
```

---

# 29. Avoid vague descriptions

Do not use:

```text
update
changes
fixes
stuff
cleanup
misc
work
new code
small fixes
improvements
final
done
```

without explaining what actually changed.

`cleanup` may be acceptable when the exact cleanup target is named:

```text
refactor(route_service): remove duplicated validation
```

is still preferable.

---

# 30. Do not overcompress history

Small commits are preferred, but do not split changes into meaningless microcommits.

Bad:

```text
feat(route_service): add method declaration
feat(route_service): add method body
feat(route_service): include vector header
feat(route_service): fix typo
```

if these all form one tiny feature.

The goal is semantic atomicity, not the maximum possible number of commits.

---

# 31. Do not overcombine history

The opposite mistake is more serious for this workflow.

Bad:

```text
feat(deadline): complete everything
```

containing:

- lectures;
- practice;
- implementation;
- tests;
- CMake;
- formatting;
- documentation.

Split aggressively when work has different purposes.

When uncertain between one large commit and two coherent smaller commits, prefer two coherent smaller commits.

---

# 32. Special rule for mixed repository work

If the working tree contains multiple unrelated tasks, explicitly separate them even if the user asks to "commit everything".

Interpret "commit everything" as:

> commit all valid changes, using as many semantic commits as necessary.

Do not interpret it as:

> create one commit containing everything.

This distinction is mandatory.

---

# 33. Commit execution safety

Do not modify source files merely to make commits look cleaner unless the user also requested code changes.

The commit specialist's responsibility is primarily:

- inspect;
- classify;
- stage;
- commit;
- report.

Do not silently rewrite user work.

Do not discard modifications.

Do not run destructive Git operations unless explicitly required and safe.

---

# 34. Existing staged changes

If files are already staged, do not assume they belong together.

Inspect the staged diff first.

If staged changes contain several semantic units, split them before committing.

Pre-existing staging is not a source of truth for commit boundaries.

---

# 35. Existing commit style

The user's older history commonly follows patterns such as:

```text
feat(src/route_service): add one-route method impl
fix(src/yandex_api): fixed stations method
chore(cmake): file dependencies updated
style(src/yandex_api): spaces
chore(tests): add new tests
```

Keep the useful structural pattern:

```text
type(scope): description
```

but improve weak wording.

Prefer:

```text
style(src/yandex_api): fix spacing
```

over:

```text
style(src/yandex_api): spaces
```

Prefer:

```text
fix(src/yandex_api): handle invalid stations response
```

over:

```text
fix(src/yandex_api): fixed stations method
```

Preserve recognizable history style without preserving its old wording mistakes.

---

# 36. Suggested decision algorithm

For every changed hunk, ask these questions in order.

### Question 1

What purpose does this change serve?

Classify it as:

- feature;
- fix;
- refactor;
- test;
- style;
- docs;
- build/config;
- educational artifact;
- other maintenance.

### Question 2

Which component or course artifact does it belong to?

Determine a useful scope.

### Question 3

Would this change still make sense if another changed file were absent?

If yes, they may need separate commits.

### Question 4

Are two changes merely related, or are they one semantic unit?

Related does not mean inseparable.

### Question 5

Would combining them make the commit subject require two unrelated clauses?

If yes, split.

### Question 6

Would splitting them create artificial meaningless microcommits?

If yes, keep them together.

---

# 37. Examples of correct grouping

## Feature plus tests

Possible:

```text
feat(route_service): add cheapest route selection
chore(tests/route_service): add cheapest route test
```

## Bug fix plus regression test

Possible single commit:

```text
fix(cached_api): recover corrupted stations cache
```

containing both the fix and one tightly coupled regression test.

## Two lectures

Good:

```text
docs(database-entity/lectures): add lectures 5 and 6
```

## Lecture plus practice

Forbidden as one commit.

Required split:

```text
docs(database-entity/lectures): add lecture 5
feat(database-entity/practice): complete practice 3
```

## Feature plus formatting

Usually split:

```text
feat(yandex_api): parse vehicle information
style(yandex_api): fix formatting
```

## CMake plus unrelated tests

Split:

```text
chore(cmake): update source dependencies
chore(tests/route_service): add transfer route tests
```

---

# 38. Examples of bad grouping

Never produce commits equivalent to:

```text
chore(project): update files
feat(project): complete task
docs(course): lecture and practice
chore(tests): add all new tests
style(project): many fixes
feat(lab): finish laboratory
```

when the diff contains more precise semantic units.

---

# 39. Final verification

Before finishing a commit session, verify:

- every intended change is committed or intentionally left uncommitted;
- no unrelated changes were mixed;
- no lecture is mixed with a practical assignment;
- tests are grouped by subsystem or purpose;
- formatting-only work is not hiding behavior changes;
- commit subjects use `type(scope): description`;
- scopes are specific enough;
- descriptions are concise and concrete;
- generated garbage is not committed;
- commit order is understandable;
- `git status` is consistent with the user's intent.

---

# 40. Reporting after commits

After creating commits, report them concisely.

Preferred format:

```text
Created 4 commits:

1. `feat(route_service): add cheapest route selection`
2. `chore(tests/route_service): add cheapest route test`
3. `docs(database-entity/lectures): add lectures 3 and 4`
4. `feat(database-entity/practice): complete practice 2`
```

If changes remain uncommitted, mention them explicitly and explain why.

Do not dump unnecessary Git command output unless requested.

---

# 41. Target result

The final Git history should have these properties:

- each commit represents one understandable unit of work;
- unrelated work is separated;
- educational artifacts are grouped by type and purpose;
- implementation history can be followed incrementally;
- commit subjects are compact and consistent;
- a future reader can understand the project evolution from `git log --oneline`;
- commits are small without becoming meaningless microcommits.

The strongest rule is:

> Never use one broad commit where several clear semantic commits can be made.

And for university repositories specifically:

> A lecture and a completed practical assignment are different semantic units and must not be committed together.