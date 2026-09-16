# English Source

---

name: language-standards
description: >
Apply my default language-specific coding standards when reading,
writing, modifying, refactoring, or reviewing source code. Use when
a task materially involves a supported programming language and
decisions involve type modeling, mutability, nullability, naming,
API design, control flow, error handling, concurrency, or idiomatic
language usage. Repository-local standards take precedence.
-----------------------------------------------------------

# Language Standards

This skill provides personal fallback standards for programming languages.

It does not replace repository-local conventions.

## Apply Repository Rules First

Before applying a language reference, inspect the repository for relevant standards, including:

* `AGENTS.md`
* `CLAUDE.md`
* `CONTRIBUTING.md`
* coding-standard documents
* formatter and linter configuration
* compiler configuration
* representative nearby code

When a repository explicitly defines a convention, follow it instead of the personal default.

Do not create style-only churn to make existing code match these references.

## Select the Language

Determine the language from the files materially involved in the task, not only from the user's wording.

Load only the references required for the current task.

If several supported languages are materially involved, load each applicable reference.

## Available References

* Typescript: `references/typescript.md`

References for additional languages may be added over time.

If no reference exists for a language, follow repository conventions and normal language practices. Do not invent a personal standard that is not documented.

## How to Use a Reference

Language references primarily guide decisions that require engineering judgment.

Examples include:

* representing domain concepts
* choosing between mutable and immutable state
* expressing absence and failure
* designing functions and APIs
* choosing language constructs
* structuring asynchronous or concurrent work

Formatting details already enforced by project tooling are not review findings unless they prevent the tooling from succeeding.

## Conflict Resolution

Use this order when language guidance conflicts:

1. Explicit user requirement
2. Repository-local documented convention
3. Existing project design constraints
4. Applicable language reference
5. General language knowledge

Existing code is evidence of project intent, but repetition alone does not make a pattern mandatory.
