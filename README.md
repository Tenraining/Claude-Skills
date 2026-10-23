# Claude Skills

A collection of [Agent Skills](https://docs.claude.com) for Claude and Claude Code, plus tooling to scaffold, validate, package and install them.

Each skill is a self-contained folder under `skills/` with a `SKILL.md` at its root. The repo includes original skills and a curated set of third-party skills, each credited to its source.

## Original skills

| Skill | What it does |
|-------|--------------|
| [react-code-review](skills/react-code-review/) | Reviews React code (`.jsx`/`.tsx` components, hooks, services, utils) against a custom [React code organization guide](skills/react-code-review/references/react-guide.md). Reports findings in three severity tiers (bug, structure, style), each with a rule reference and a minimal before/after fix. Includes trigger and output tests. |
| [react-dashboard-structure](skills/react-dashboard-structure/) | Plans, scaffolds or reorganizes the `src/` tree of a React dashboard (charts, metric cards, filters, card grids, expanded panels) using a custom [structure guide](skills/react-dashboard-structure/references/structure-guide.md): a placement table, tie-breaker rules, naming conventions and a full example tree. Includes trigger and output tests. |

The two React skills are designed to run together. `react-dashboard-structure` owns where files go and what they're called; `react-code-review` owns what's inside them. Asked for both, they produce one combined report with no duplicate findings, and on dashboard projects the structure guide takes precedence on layout (no barrel files, area folders), so the reviewer doesn't flag it.

## Third-party skills

These skills are included unchanged except where noted, under their original licenses.

| Skill | What it does | Source |
|-------|--------------|--------|
| [caveman](skills/caveman/) | Terse "caveman" replies to save tokens. `/caveman` on, "stop caveman" off. | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) (Apache-2.0) |
| [ultracave](skills/ultracave/) | Extra-terse caveman mode (`/caveman ultra`). | caveman (Apache-2.0) |
| [caveman-explore](skills/caveman-explore/) | Read-only repo explorer that returns `path:line` citations. | caveman (Apache-2.0) |
| [investigate-first](skills/investigate-first/) | Diagnose ambiguous failures before editing. | caveman (Apache-2.0) |
| [safe-refactor](skills/safe-refactor/) | Restructure code while preserving behavior. | caveman (Apache-2.0) |
| [verify-and-stop](skills/verify-and-stop/) | Prove work meets acceptance conditions without expanding scope. | caveman (Apache-2.0) |
| [typeui-fundamentals](skills/typeui-fundamentals/) | UI/UX design principles: hierarchy, spacing, typography, interaction laws and WCAG accessibility. | [bergside/typeui](https://github.com/bergside/typeui/tree/main/skills/fundamentals) (MIT) |

**Local changes:** in `skills/caveman/README.md` and `skills/ultracave/README.md`, relative links to files that exist only in the upstream repo now point to the upstream GitHub repo.

## Repository layout

```
.
├── skills/<skill-name>/
│   ├── SKILL.md        # required: frontmatter (name, description) + instructions
│   ├── references/     # optional: longer docs Claude reads only when needed
│   ├── scripts/        # optional: helper code Claude can run
│   ├── assets/         # optional: templates, images, sample files
│   └── tests.md        # prompts that should / shouldn't trigger the skill
├── templates/          # starting files used by new-skill.sh
└── scripts/            # scaffold, validate, package and install helpers
```

## Usage

```bash
# Create a new skill from the template
./scripts/new-skill.sh my-new-skill

# Check every skill's frontmatter (name format, folder match, description length)
./scripts/validate.sh

# Zip skills for upload to claude.ai (outputs to dist/)
./scripts/package.sh              # all skills
./scripts/package.sh my-new-skill # just one

# Link skills into Claude Code (~/.claude/skills) so edits apply immediately
# (symlinks on macOS/Linux, directory junctions on Windows, so no admin rights are needed)
./scripts/link-claude-code.sh
```

## Authoring guidelines

- **The `description` decides when the skill loads.** State what it does *and* when to use it.
- **Keep `SKILL.md` lean.** Put long reference material in `references/` and point to it.
- **Use scripts for deterministic steps** (parsing, formatting, filling templates).
- **Test triggering** with the prompts in each skill's `tests.md` after editing the description.

See the [official docs](https://docs.claude.com) for current frontmatter fields and limits.

## License

Original work in this repo (`react-code-review`, `react-dashboard-structure`, `scripts/`, `templates/`) is released under the [MIT License](LICENSE).

Third-party skills keep their own licenses: the caveman skills are Apache-2.0 ([`skills/caveman/LICENSE`](skills/caveman/LICENSE)) and `typeui-fundamentals` is MIT ([`skills/typeui-fundamentals/LICENSE`](skills/typeui-fundamentals/LICENSE)).
