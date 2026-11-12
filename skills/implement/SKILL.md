---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask. If a blocker is unfinished (its code is in no branch you can merge), ask right then, before reading further.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Verify with the fast checks: run the single unit-test files you touched while implementing, and those files plus typechecking before each commit. Leave the full unit-test suite to whatever already runs it before merge: the repo's PR CI (read that result once the branch is pushed) or a pre-push hook (it runs at push). With neither, run it once at the end. When you break code on purpose to prove a test catches it, try two or three core decisions and stop each run at its first failure. Save test output to a file and read that instead of re-running. End-to-end (Playwright) runs happen when the user schedules them.

Code review happens later, once per PR, in a separate session — a fresh reviewer is not anchored on this session's reasoning.

Commit your work to the current branch, one commit per kind of change. If the branch is stacked on another draft PR's branch, merge that branch again first, since it may have moved. Put what the later PR and review sessions need in the commit message body: facts confirmed against the live server, and decisions taken without asking. Push and open a PR when the user asks.
