---
name: react-dashboard-structure
description: Lay out the files and folders of a React dashboard app (charts, metric cards, filters, card grids, expanded detail panels) using the user's own structure guide, and report a file tree with placement reasons. Use this whenever the user starts a new React dashboard or analytics front end, asks where a new component, hook, service, util or constant should go, asks how to organize or restructure a dashboard's src/ folder, or wants a starter file tree — even if they don't say "structure" or mention the guide. Also use it alongside react-code-review when the user wants a dashboard's structure and code checked together.
---

# React Dashboard Structure

Plan, scaffold or reorganize a React dashboard against the user's guide in `references/structure-guide.md` and produce a file tree they can build from right away.

The guide is the source of truth. Read it in full every time, because the user edits it over time, so don't rely on memory of its rules. Where the guide and common React habits disagree, the guide wins (e.g. it says no `index.js` barrel files, so don't add them even though many projects use them).

## When to use

- The user starts a new React dashboard, analytics or reporting front end and needs the `src/` tree.
- The user asks where a new file belongs ("where does a hook that loads chart data go?").
- The user wants to reorganize an existing dashboard whose `src/` has grown messy.
- Not for reviewing the code inside files (use `react-code-review`), styling or visual design, or non-React projects. Those don't need the guide's placement rules.

## Steps

1. **Read the guide** (`references/structure-guide.md`).
2. **Gather the context.** Work out what you are placing:
   - *New dashboard:* list the pages, visuals (chart types, tables), card types on the grid, filters, shared state and data sources. Ask only if the user gave too little to name any parts.
   - *Existing project:* read its `src/` tree (skip `node_modules`, build output and generated files) and the first lines of files whose purpose isn't clear from the name.
   - *Single file:* read the file or description the user gave.
3. **Name things for the user's domain.** The guide's example names are placeholders. Never reuse them unless they fit the user's dashboard.
4. **Place each file** with the placement table (§3). When a file could fit two folders, follow the tie-breakers (§4).
5. **Check the result** against the self-review checklist (§7), then write the output.

## Placement judgment

Place by what the code does, not by what it is named today. A file called `helpers.js` that calls `useState` is a hook. A component file that calls `fetch` belongs in the tree as a component plus a service.

Start code next to the one component that uses it and move it to a shared folder only when a second user exists. Don't create empty folders or areas "for later". An area with one component goes in the closest existing area (§2).

Only move what breaks the guide. In a restructure, a file that is already in an acceptable place stays put, even if you would have named it differently. A short, accurate moves list is more useful than a full reshuffle that breaks every import.

## Output format

Use this structure:

~~~markdown
# Dashboard Structure: <project or feature name>

**Summary:** <1–2 sentences: what the dashboard holds and the main layout decision.>

## File tree
```
src/
├── ...           # one short comment per non-obvious file or folder
```

## Why it's laid out this way
- <2–5 bullets tying the main choices to the guide, e.g. "§4 Context or hook: filters share state through `context/`, so charts don't receive filter props.">

## Moves
| From | To | Imports to update |
|------|----|-------------------|

## Adding to it later
- <1–3 bullets: where the next likely files go, e.g. a new chart type or a second page.>

## Not checked
<Only if relevant: what you didn't look at, e.g. the code inside the files when react-code-review isn't run. One line each.>
~~~

Guidelines for the output:
- **New dashboards** omit the **Moves** section.
- **Restructures** start with a one-line **Scope** under the title saying how many files were checked and what was skipped. List every move in **Moves**, and show the tree after the moves.
- **Single "where does this go?" questions** skip the template: give the path and one sentence citing the guide section.
- **Comments in the tree** stay short, and only on files whose name doesn't say what they do.
- Omit any section with nothing in it.

## Creating the files

By default, report only — don't create or move files. If the user asks you to create the structure, make each file with its one-line purpose comment and a minimal stub (an empty component, a hook that returns placeholder values), not a full implementation. If the user asks you to apply a restructure, move the files in the order of the **Moves** table, update every import, and then list what changed.

## Using with react-code-review

The two skills split the work: this skill decides where files go and what they are called, and `react-code-review` checks the code inside them.

- **Asked for both** (e.g. "review my dashboard's structure and code", "set up the folders and check my components"): if `react-code-review` is available, run this skill first, then `react-code-review` on the files. Give one answer, with the structure report first and the code review under its own heading. Report each finding once: placement and file naming belong here, and everything inside a file belongs to the code review.
- **Where the two guides disagree** on a dashboard project, this guide wins on structure: area folders over feature folders, no `index.js` barrels, `export default function <Name>`, `lib/` for the HTTP client, and one plain `.css` file per component. The React guide wins on everything inside a file.
- **Moves that change code** (e.g. splitting a `fetch` out of a component into a service) follow the React guide's rules for the new code.
- If `react-code-review` isn't available, do only the structure part and add a **Not checked** line saying the code inside the files wasn't reviewed.

## TypeScript

Everything applies to `.tsx`/`.ts` too. Shared types for one resource go beside its service (`services/ordersService.types.ts`) or in a `types/` folder once several services share them. Prop types stay in the component file.

## References

- The rules: `references/structure-guide.md` (read in full every time; §3 is the placement table, §6 the example tree, §7 the checklist).
