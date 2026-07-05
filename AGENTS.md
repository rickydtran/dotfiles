# Ricky's agent instructions

These are common instructions for Ricky's agents across all scenarios.

## General Guidelines

- Write concise commit messages that still let an AI reading `git log` infer what changed and why without opening the diff.
- Comments explain the non-obvious why of code that exists.
  Don't comment the absence of something, leave tombstones for removed code, or assert rationale that drifts stale; the diff and `git log` carry that.
- Never use the em dash. Use a plain hyphen instead.
- Never manually modify CHANGELOG.md or any file marked as auto-generated.
- When writing or substantially editing long Markdown files, put each full sentence on its own line.
  Preserve normal Markdown structure, but don't wrap multiple sentences onto one physical line.
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long-term maintainability.
- When doing bug fixes, always start by reproducing the bug end-to-end, as close to real end-user conditions as possible.
  This makes sure you find the real problem so your fix actually solves it.
- When end-to-end testing a product, be picky about the UI and obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, get it fixed.
- Apply that same high standard to engineering excellence: format, lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.

## Context files (Ricky)

- When work would benefit from Ricky's viewpoints, read `~/OPINIONS.md`.
- When speaking or posting as Ricky (his identity), read `~/VOICE.md` to see how Ricky talks.
