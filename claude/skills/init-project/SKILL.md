---
name: init-project
description: Turn "what does done look like?" into a checklist mission-control can evaluate. Writes measurable checks for a project's current phase into progress.toml, so its progress bar is computed from real predicates rather than a hand-ticked list that goes stale.
---

# init-project

Config lives at `~/dotfiles/progress.toml` (`mission_control/config.py` in
`~/Desktop/projects/tui-mission-control` reads it; the format is documented
there). This skill exists to fill in one thing that file cannot get from
anywhere else: **what counts as done**, expressed as a predicate the app can
evaluate, not a sentence a human has to remember to update.

Five check types exist. Nothing else does:

| type | passes when | example `value` |
|---|---|---|
| `path` | a file/dir exists, relative to the project's `path` | `"results/baseline.json"` |
| `git_tag` | a tag exists in the repo | `"v0.1"` |
| `cmd` | a shell command exits 0 (10s timeout, runs in the project dir) | `"pytest -q tests/test_eval.py"` |
| `gh_pr` | `gh pr view <value> --json state` reports `MERGED` | `"owner/repo#412"` |
| `manual` | a `done = true/false` flag you flip by hand | — the escape hatch, use sparingly |

## 1. Find the project

- If invoked with an argument, treat it as the project name.
- Otherwise match the current directory against `path` in `progress.toml`
  (longest-prefix match if it's a subdirectory) — the same resolution
  `mc brief` does.
- If nothing matches, this is a new project: ask whether to run `mc new <name>`
  first (in `~/Desktop/projects/tui-mission-control`, `uv run python -m
  mission_control new <name>`) or whether the directory/entry already exists
  under a different name.

Read the project's current block, including any existing
`[[projects."name".checks]]`. If checks already exist, say what's there and
ask whether this run is adding to the current phase, or defining the next one
— don't restart from zero.

## 2. Scope: the current phase only

Do **not** try to extract checks for every future phase in one sitting. Ask
what the phase names roughly look like (3–5 words each is plenty — "baselines",
"writeup", "ship") so `phase` can be set sensibly, but only build concrete
checks for the phase that's actually active right now. Future phases aren't
designed yet; checks written against them today are a guess, and guesses are
exactly the kind of thing this tool exists to replace with fact. Add their
checks when they become current — this skill is meant to be re-run per phase,
not once per project.

## 3. Draw out concrete checks for the current phase

Ask: "what already exists, and what's the next thing that has to be true for
this phase to be done?" Then for each candidate the user offers, **refuse
anything that isn't a predicate**:

- "writeup" → not a check. "`writeup.md` exists and is over 800 words"? That's
  two checks, or a `manual` if word count isn't worth scripting.
- "working" / "solid" / "polished" → ask what a stranger would look at to
  confirm it. A passing test suite? A merged PR? A tagged release? Map it to
  one of the five types.
- If nothing observable exists yet and scripting one isn't worth it right now,
  `manual` is fine — but say out loud that it's the type that can silently go
  stale, same as the checklist this tool replaced. Prefer it only when a real
  predicate genuinely doesn't exist (aesthetic judgment calls, decisions made
  outside any file).
- `cmd` checks run on `c` (roster) or `mc check` — never automatically, never on
  every session start. `mc doctor` does not evaluate them at all. `mc brief`, which runs on
  every `SessionStart`, only ever shows `path`/`git_tag`/`manual` checks for
  exactly this reason. Don't propose a `cmd` check that takes more than a few
  seconds, or hits the network — that's what `gh_pr` is for.

Aim for 3–6 checks for the current phase. Fewer than that and the percentage
is too coarse to mean anything; more and it's busywork.

## 4. Write it

Append to `~/dotfiles/progress.toml` with the Edit tool — don't rewrite the
whole file, and don't reflow existing formatting. Match the file's existing
convention: checks live in `[[projects."<name>".checks]]` array-of-table
blocks, appended after the last such block (TOML doesn't care about physical
position relative to `[projects."<name>"]`, only the file's readability does).
If `path` had a trailing `# checks = run /init-project...` comment, that
comment can go now that real checks exist.

```toml
[[projects."<name>".checks]]
name  = "dataset loader"
type  = "path"
value = "results/train.parquet"

[[projects."<name>".checks]]
name  = "writeup ≥ 800w"
type  = "manual"
done  = false
```

Also set/update `phase` on the project's own block if it's stale.

## 5. Confirm

Run `uv run python -m mission_control doctor` (from
`~/Desktop/projects/tui-mission-control`) and read back the resulting
`ok/total checks` line for this project, so the user sees the real number
before moving on — not a promise that it was written correctly.
