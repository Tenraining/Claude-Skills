---
name: react-code-review
description: Review React code (.jsx/.tsx components, hooks, services, utils) against the user's own React code organization guide and report violations by severity with fixes. Use this whenever the user asks to review, check, audit, critique, or "look over" React code, asks whether a component follows good practices or their conventions, pastes a React component and asks what's wrong with it or how to improve it, or asks for a pre-PR/self-review of React files — even if they don't say "review" or mention the guide.
---

# React Code Review

Review React code against the user's guide in `references/react-guide.md` and produce a report they can act on quickly.

The guide is the source of truth. Read it in full before every review — the user edits it over time, so don't rely on memory of its rules. Where the guide and general React wisdom disagree, the guide wins (e.g. it says inline functions are fine and memoization only after measuring, so don't flag missing `useCallback`).

## When to use

- The user asks to review, check, audit or critique React code (`.jsx`, `.tsx`, hooks, services, utils), or asks whether it follows their conventions.
- The user pastes a component and asks what's wrong with it or how to improve it.
- A pre-PR self-review of React changes.
- Not for writing new React features from scratch, debugging a specific runtime error, or reviewing non-React code (backend, CSS-only changes). Those don't need the guide's checklist.

## Steps

1. **Read the guide** (`references/react-guide.md`).
2. **Gather the code.** Read every file the user shared or pointed to. If they named a folder or project, read the React files in it (components, hooks, services, utils, constants) — skip `node_modules`, build output, and generated files.
3. **Decide what you can judge.** Some rules need project context:
   - *Single file or snippet:* review only what's visible in it. Don't flag folder placement, lazy-loaded routes, or barrel imports unless the file itself shows the problem (e.g. a `fetch` call inside a component is visible; whether `services/` exists is not).
   - *Whole project or folder:* also check structure (section 1), code splitting (section 4), and modularization (section 9).
4. **Go through the code section by section**, using the section 11 checklist as a final pass so nothing is skipped.
5. **Classify each finding** by severity (below), then write the report.

## Severity

Severity tells the user what to fix first. Assign it by consequence, not by which section the rule lives in.

- **🔴 Bug** — causes incorrect behavior, crashes, lost state, or leaks *today*. Examples: hooks called conditionally or after an early return; mutating state (`items.push`); a number on the left of `&&` (renders `0`); a component defined inside another component; an effect that starts a timer/subscription/listener/fetch without cleanup; missing or wrong effect dependencies that cause stale values or loops; `key={index}` on a list that can change; `<ShowIf>`-style wrappers whose children assume the condition is true; fetch without a `res.ok` check.
- **🟠 Structure** — works, but makes the code harder to change, test, or reuse. Examples: `fetch`/API calls in components; derived state stored in state + effect; props copied into state; value-mapping `switch`/if chains that should be lookups; lookup objects defined inside the component; business logic or calculations inside the component instead of `utils/`/hooks; components over ~200 lines or JSX nested more than 3–4 levels; nested ternaries; prop overload instead of composition.
- **🟡 Style** — naming, file order, import order, magic values, unnamed complex conditions, comments explaining *what* instead of *why*, long comments (more than two lines, or paragraphs that should be a one-line description). Group all long comments into one finding listing the file:line of each, with a shortened version of the worst one.

When a finding could fit two levels, ask "will a user hit a problem because of this?" If yes, it's a bug. A **latent bug** — code that would break under a condition the current data or UI can't produce yet — goes under Structure, with a sentence saying what would trigger it. Calling it a bug overstates it; leaving it out loses the most useful finding in an otherwise clean codebase.

Before reporting a bug, trace whether it's actually reachable (e.g. check the data or props that would trigger it). This is where reviews of good code go wrong: a plausible-looking bug that can't happen erodes trust in the whole report.

Only report real violations. If something is a judgment call the guide explicitly allows (a `switch` inside a reducer, a two-case ternary, index keys on a static list, `document.title` effect without cleanup), leave it alone. A short, accurate report is more useful than a long one padded with nitpicks — the user will stop trusting the tool if it cries wolf.

## Output format

Use this structure:

~~~markdown
# React Review: <file or project name>

**Summary:** <1–2 sentences: overall state and the most important thing to fix.>
🔴 <n> bugs · 🟠 <n> structure · 🟡 <n> style

## 🔴 Bugs

### 1. <Short title> — `File.jsx:<line>`
**Rule:** <guide section number and rule, e.g. "§7 Never mutate">
**Why it matters:** <one or two sentences on the concrete consequence in *this* code>
```jsx
// Before
<the offending lines, trimmed to what's relevant>

// After
<the minimal corrected version>
```

## 🟠 Structure
...

## 🟡 Style
...

## What's good
<2–4 bullets on things the code does well, so the user knows what to keep doing. Skip if nothing stands out.>

## Worth planning for
<Only if relevant: not violations today, but places where a planned change (noted in comments, TODOs, placeholders) will force one — e.g. a service whose comment says it'll become async. One or two bullets.>

## Not checked
<Only if relevant: rules that need context you didn't have (folder structure, route splitting, lint/format status). One line each.>
~~~

Guidelines for the report:
- **Whole-project reviews** start with a one-line **Scope** under the title saying how many files were reviewed and what was skipped (tests, CSS, data constants), so the user knows how far the verdict reaches.
- **Line numbers** refer to the file as given. If the code was pasted without a file name, use the component name instead.
- **Group repeated violations.** Five non-`is` booleans are one finding listing all five names, not five findings.
- **Before/after snippets stay minimal** — just enough lines to show the change. For a structural change (e.g. moving a fetch into a service + hook), show the new shape in a compact form rather than rewriting the whole file.
- Omit any severity section with no findings.
- Always end with one line reminding the user to run their formatter and ESLint (with `eslint-plugin-react-hooks`), since formatting and lint status can't be verified by reading.

## Fixing the code

By default, report only — don't edit files. If the user asks you to fix the issues (or asks for a "fixed version"), apply the fixes in severity order, keep behavior the same, and then list what changed. Structural moves that create new files (a service, hook, or constants file) are fine when fixing, but mention each new file.

## Using with react-dashboard-structure

The two skills split the work: `react-dashboard-structure` decides where files go and what they are called, and this skill checks the code inside them.

- **Dashboard projects.** A project follows the dashboard structure guide when it has `components/<area>/<Component>/` folders, a `lib/httpClient.js`, and no `index.js` barrels, or when the user says so. In that case, leave folder placement and file naming to `react-dashboard-structure`. Skip the §1 folder and component-folder rules and the §9 barrel rule. Don't flag area folders instead of feature folders, missing `index.js` files, `export default function Name` in place of an export at the end of the file, or the `lib/` folder. Every other rule still applies.
- **Asked for both** (e.g. "review my dashboard's structure and code"): the structure report comes first, then this review under its own heading. Report each finding once: placement and file naming belong to the structure report, and everything inside a file belongs here.
- **Fixes that create files** (a new service, hook or constants file) go where the dashboard structure guide's placement table puts them.
- If `react-dashboard-structure` isn't available, review as normal.

## TypeScript

Everything applies to `.tsx`/`.ts` too. Type annotations, interfaces, and generics are not clutter and don't count toward "keep it small" judgments beyond common sense. Naming rules apply to types as well where they make sense (components' prop types like `UserCardProps` are PascalCase).

## References

- The rules: `references/react-guide.md` (read in full before every review; §11 is the checklist).
