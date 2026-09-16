# Global Agent Instructions

These instructions define my default preferences across repositories.

Keep this file small and stable. Detailed procedures belong in skills. Repository-specific knowledge belongs in the repository.

Always answer to user in Korean.

## Instruction Priority

Follow the most specific applicable instruction.

In general:

1. Explicit user instructions
2. Repository or directory-specific instructions
3. Applicable project documentation and established conventions
4. Personal skills and standards
5. These global defaults

Repository-local standards override personal defaults unless the user explicitly requests otherwise.

## Repository First

Before changing code:

* inspect the relevant code and surrounding context
* discover repository-local instructions and conventions
* inspect existing tooling, scripts, tests, and configuration
* prefer information available from the repository over assumptions

Do not duplicate facts in global instructions when they can be cheaply discovered from the environment.

## Use Skills

Use specialized skills when the task fits them.

Skills contain detailed procedures and reusable engineering disciplines. Do not reproduce their instructions here.

When working with source code in a supported language, apply the `language-standards` skill.

Repository-local language conventions take precedence over personal language defaults.

## Preserve Local Intent

Treat existing code as important context, not as unquestionable best practice.

Prefer established project patterns when they are reasonable and compatible with the requested change.

Do not reproduce an existing pattern when it clearly conflicts with:

* correctness
* security
* explicit instructions
* documented repository standards

Introduce a new pattern only when there is a concrete reason.

## Scope Discipline

Make the smallest coherent change that fully satisfies the task.

Avoid unrelated:

* refactoring
* renaming
* formatting
* dependency changes
* architectural changes
* cleanup

Adjacent problems may be reported without being modified.

## Verification

Verification is part of implementation.

Use the repository's existing verification mechanisms where applicable, including tests, type checks, linting, static analysis, compilation, or builds.

Prefer focused verification first, then broader verification when justified by the change.

Do not claim a check passed unless it was actually run.

If verification cannot be completed, state what remains unverified.

## Completion

Before declaring a task complete:

* review the final diff or changed artifacts
* confirm the requested outcome is addressed
* check for unintended changes
* remove temporary debugging artifacts
* report meaningful verification gaps or unresolved assumptions

Do not claim more certainty than the available evidence supports.
