---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Verify with the fast checks: run typechecking and single unit-test files regularly, and the full unit-test suite once at the end. End-to-end (Playwright) runs happen when the user schedules them.

Code review happens later, once per PR, in a separate session — a fresh reviewer is not anchored on this session's reasoning.

Commit your work to the current branch, one commit per kind of change. Put what the later PR and review sessions need in the commit message body: facts confirmed against the live server, and decisions taken without asking. Push and open a PR when the user asks.
