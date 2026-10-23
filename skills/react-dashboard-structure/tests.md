# Trigger tests for react-dashboard-structure

Try these prompts after changing the description to check the skill loads when it should.

## Should trigger

- "i'm starting a react dashboard for gym attendance stats, can you set up the folders"
- "where should a hook that loads the revenue chart data go?"
- "my dashboard's src folder is a mess, how should I reorganize it?"
- "give me a file tree for a React analytics app with KPI cards and filters"
- "review my dashboard's structure and code" (together with react-code-review)

## Should NOT trigger

- "review my SalesChart.jsx for bugs" (code review only, use react-code-review)
- "make the chart colors accessible" (visual design)
- "set up the folder structure for my Spring Boot API" (not React)
- "how do I lazy-load a route in React?" (a concept question)

## Output checks

When it triggers, the answer should:

- **New dashboard:** a Summary, then a full `src/` tree with `pages/`, `components/<area>/<Component>/`, `context/`, `hooks/`, `services/`, `lib/`, `utils/` and `constants/`, plus the "Why" and "Adding to it later" sections. No Moves section.
- **Domain names:** components named for the user's domain (e.g. `AttendanceTile`), not the guide's placeholders (`StatTile`, `GraphShell`).
- **"Where does this go?":** a single path plus one sentence citing the guide section, not the full template.
- **Restructure:** starts with a Scope line; a Moves table with the imports to update; files already in an acceptable place are not moved.
- **Misnamed file** (a `helpers.js` that calls `useState`): placed in `hooks/` as `use<Thing>.js`, not in `utils/`.
- **No barrels:** no `index.js` files in component folders.
- **Used with react-code-review:** one answer, the structure report first, then the code review under its own heading; no finding repeated in both; the code review doesn't flag area folders, missing `index.js` files or `export default function`.
- **Without react-code-review:** a Not checked line saying the code inside the files wasn't reviewed.
