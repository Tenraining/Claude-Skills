# Trigger tests for react-code-review

Try these prompts after changing the description to check the skill loads when it should.

## Should trigger

- "can you check src/pages/OrderDashboard.jsx against my react rules? i think its kind of messy"
- "Before I open a PR, does TodoList.tsx follow our conventions?"
- "whats wrong with this component" (followed by a pasted React component)
- "review my uncommitted React changes"
- "/react-code-review src/components/orders"
- "is this hook written properly? src/hooks/useWindowWidth.js"

## Should NOT trigger

- "build me a React component that shows a list of orders with a filter dropdown" (writing new code, not reviewing)
- "my React app crashes with 'Cannot read properties of undefined (reading map)' on load, why?" (debugging one error)
- "review my Spring Boot controller for security issues" (not React)
- "explain how useEffect cleanup works" (a concept question, no code to review)

## Output checks

When it triggers, the review should:

- **Messy component** (hook after an early return, uncleared `setInterval`, `data.push` then `setData(data)`, `{list.length && ...}`, `key={index}` on a filtered list, component defined inside a component): all six listed as 🔴 bugs.
- **Clean component** using a reducer `switch`, a `document.title` effect with no cleanup, and a two-case ternary: none of those three flagged.
- **Pasted snippet with no file name:** findings located by component name, and no folder-structure findings.
- **Long comments** (a 4-line comment block above a component, a 3-line comment inside JSX): one 🟡 Style finding listing both locations, with a one-line rewrite. A one-line file description and a one-line *why* comment are not flagged.
- **Whole project:** starts with a Scope line; any bug that can't actually happen with the current data is filed under 🟠 Structure, not 🔴 Bugs.
- **Dashboard project** (area folders, `lib/httpClient.js`, no `index.js` files, `export default function` components): none of those four flagged; in-file rules still checked.
- **Asked for both skills** ("review my dashboard's structure and code"): one answer, the structure report first, then the code review; no finding repeated in both.
