---
name: write-typst
description: Create, edit, structure, or review Typst (.typ) documents and multi-file Typst coursework, especially mathematical homework, proofs, reports, and university labs. Use for compiling-ready Typst source, correcting Typst markup and math notation, building shared preambles, tables, automata, or layout, and checking a Typst project before delivery.
---

# Write Typst

Produce source that compiles, reads naturally in Russian, and matches the existing project before trying to improve its appearance.

## Workflow

1. Inspect the project tree and the entry `.typ` file. Read its imports, includes, local helpers, packages, page settings, and any title files before editing a task.
2. Preserve the established architecture. For a multi-file project, put global page/style settings in the preamble, include every task from the entry file, and import the preamble in each task with the correct relative path.
3. Write the solution first. Explain the decisive idea, then the calculation, proof, construction, or answer. Do not turn every small point into a rigid template.
4. Apply the mathematical and layout rules in [references/typst-rules.md](references/typst-rules.md).
5. Compile the actual entry file when a compiler is available. Fix syntax, missing imports, overflowing tables/formulas, and page-break mistakes. Do not report a document as finished merely because its source looks plausible.

## Project structure

Use a main file for composition, not for long task answers:

```typst
#import "../preambule.typ": *
#include "../title.typ"

#use-style-clean("Course name")[
  #include "tasks/task1.typ"
  #include "tasks/task2.typ"
]
```

Each task should import the shared preamble and use a level-1 heading:

```typst
#import "../../preambule.typ": *

== Problem 1: Short title
```

Do not invent package imports or helper names. If a requested feature needs a package, add the exact import in the closest appropriate scope and keep versions consistent. The existing projects use `@preview/finite` for automata, `@preview/xarrow` for long arrows, and `@preview/equate` for breakable numbered equations.

## Structure and prose

- Use `+` for principal task items. Use `#enum(numbering: "(a)", full: false, spacing: 12pt)[...]` for lettered subitems. Do not mix them at the same nesting level.
- Use headings only for real sections. Prefer `==` for a problem, `====` for a substantial part, then concise bold labels such as `*Идея.*`, `*Доказательство.*`, `*Ответ:*`, `*База:*`, and `*Переход:*`.
- Write in Russian unless the task or course requires English. Keep standard technical terms in their established form.
- Make the text sound like a good student solution: concrete, uneven in a natural way, and free of filler. Avoid canned openings and repeated transitions such as «Таким образом», «Важно отметить», «В данном случае».
- State the invariant or interpretation immediately next to a construction. For example, after defining a DFA state, say what information that state represents.
- For a proof by contradiction, explicitly assume the opposite and identify the contradiction. For induction, separate base and step. Add `$square$` only after a genuine completed proof.

## Mathematics and Typst notation

- Put every mathematical object in `$...$`. Keep short formulas inline; reserve display math for systems, long derivations, or formulas that need visual emphasis.
- Never put terminal punctuation inside a display formula.
- Parenthesize any non-atomic numerator, denominator, index, or exponent: `$(1 - x^(n + 1))/(1 - x)$`, `$a_(n - 1)$`, `$2^(n - 1)$`.
- Distinguish a sequence term `$a_n$`, a function `$f(x)$`, and the $n$-th function `$F_n (x)$`. Use a space before the argument in the last case to avoid visually turning the index into `n(x)`.
- Write several initial conditions as `$(a_0, a_1, a_2) = (3, 2, 6)$`, not as one invented tuple index.
- Keep prose outside formulas. Use Typst symbols such as `$in$`, `$subset.eq$`, `$emptyset$`, `$epsilon$`, `$Sigma^*$`, `$backslash$`, `$=>$`, and `$equiv$` rather than pasted Unicode approximations where the project already uses Typst math notation.
- For sums, products, and limits, group complex bounds: `$sum_(0 <= k <= n) a_k$`, `$prod_(i = 1)^m (1 - x^i)$`.

## Tables, diagrams, and layout

- Use a table when values, cases, or transitions are compared along the same axes. Give columns deliberate widths such as `(1.2fr, 2fr, 2fr)`, use `table.header(...)`, and keep cells concise.
- Reuse the preamble's table defaults. Add local `stroke`, `inset`, or `align` only when a table needs different settings.
- Pair an automaton with its transition table when both clarify the same construction. Define the states and invariant in text; a diagram is evidence, not a substitute for explanation.
- Use `#grid` with `#align(center)` for an automaton-plus-table layout. Use custom automaton positions only where automatic layout is unclear.
- Define small local helpers with `#let` only if a repeated visual unit genuinely occurs several times. Keep the helper beside the task that owns it unless it is broadly reusable.
- Use `#pagebreak()` only between large blocks or when a layout actually needs it. A blank source line makes a new paragraph; do not use `\\` as routine paragraph spacing.

## Final review

Read [references/typst-rules.md](references/typst-rules.md) for the full checklist. Before delivery, verify imports and include paths, list nesting, formula grouping, the completeness of proofs, table width, and the rendered PDF if compilation is possible.
