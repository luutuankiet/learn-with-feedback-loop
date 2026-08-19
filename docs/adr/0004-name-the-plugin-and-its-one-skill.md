# Name the plugin `learn-with-feedback-loop` and its one skill `learn`

The plugin is `learn-with-feedback-loop`. Its single skill is `learn`, living in
`skills/learn/`, and it is invoked as `learn-with-feedback-loop:learn`.

This supersedes the naming half of *Merge the three skills into one, with a router
and on-demand references*, which recorded the merged skill as `learn-with-reps`.
Everything else that record says still holds; only the name moved.

## The question this answers had already half-dissolved

It was written as a collision: the repository was `learn-with-reps` and so was one
of its three skills, which forces the `write-pr:write-pr` shape — one word twice.
Both halves of that premise expired before it was worked. The repository rename
dissolved the collision as a side effect, and the merge then collapsed three skill
names to one. What was left was a pair of names and nothing else.

## The plugin keeps the convention; the skill declines it

The sibling pointer entries in the collection this plugin is served from all use
one name in three places — repository, marketplace entry, `plugin.json`. That is
kept on the plugin half, because "named for its repository" is a rule that
survives the author not being in the room.

The skill half declines it. `learn-with-feedback-loop:learn-with-feedback-loop` is
forty-eight characters of the same word twice. `learn-with-feedback-loop:learn-with-reps`
was the other candidate: it restates the loop twice, and it keeps a name this
repository was in the middle of retiring.

`learn` works **because the prefix already carries the meaning**. With one entry
point, the qualified name reads as a subject rather than a path, and it says the
one true thing about the skill: this is what you invoke to learn. `run` was
considered and dropped — it names the act of invoking rather than what is invoked.

## The load-bearing dependency

A one-word name carries little on its own, so the skill's `description` does the
discovery work instead. **If that description is ever thinned, the name stops
helping an agent find the skill.** That is the price of the short name, and it is
paid in a field that looks safe to edit.

## The directory moves with the name

`skills/learn-with-reps/` became `skills/learn/` and the frontmatter `name:`
became `learn`. Why they can never diverge — `plugin.json` holds a path, the
frontmatter holds the invocation name, and nothing checks that they agree — is
argued in *The plugin manifest carries no version, and owns the skills
allowlist*, which is where the manifest that depends on it lives.
