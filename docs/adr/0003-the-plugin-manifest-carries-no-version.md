# The plugin manifest carries no version, and owns the skills allowlist

`.claude-plugin/plugin.json` names the plugin `learn-with-feedback-loop`, declares
one skill path, and deliberately omits the `version` key. `claude plugin validate`
passes with warnings; `claude plugin validate --strict` **fails**, and that failure
is the intended state rather than a defect to fix.

This repository is consumed as a pointer entry in a marketplace manifest that
carries no `ref` and no `sha`, so a consumer resolves the default branch on every
update and clones at install time. Nothing is vendored.

## Why there is no version key

A declared `version` names the plugin's cache directory on the consumer's machine.
A version that is declared once and then never bumped therefore produces a cache
directory that can never be recreated: the update reports success, the directory
is already present, and not one byte changes. The failure is silent on both sides
— the publisher sees a green update, the consumer keeps running old text.

Omitting the key makes the cache key on the source commit sha instead, so every
push to the default branch is a new cache entry by construction. The rule is
inherited from the collection that serves this plugin, which caught the static-
version bug in the act on a sibling repository.

The cost is that `--strict` cannot pass, because strict treats the missing-version
warning as an error. That is the whole trade: strict validation, or updates that
actually arrive. Anyone reaching for `--strict` in CI here should expect the
failure and not "fix" it by adding the key.

`validate` also warns that the root `CLAUDE.md` is not loaded as plugin context.
That is correct and needs no action — `CLAUDE.md` is the eleven-byte bridge for
someone working *in* this repository, not something shipped to a consumer.

## Why the allowlist lives here and not in the collection

`skills[]` is an allowlist of **paths**, and it genuinely restricts what loads.
Paths change when directories are renamed, and only this repository can rename its
own directories. Holding the allowlist upstream would mean every rename here lands
as a consumer-visible load failure that this repository cannot see and the
collection has no reason to expect. Keeping both in one tree makes a rename a
single atomic edit.

The same reasoning fixes the directory name to the skill's own frontmatter `name`.
The manifest holds a path, the frontmatter holds the invocation name, and nothing
checks that they agree — a directory disagreeing with its own frontmatter is a
trap with no error message. They are kept identical so the disagreement cannot
arise.
