# React Code Organization Guide

**Guiding principle:** Someone new should be able to guess what a file does from its name, and what a component does from its first 10 lines.

## Contents
1. Structure
2. Component Basics
3. Object Lookups over Switch
4. Code Splitting
5. Naming
6. Advanced Patterns
7. Logic Out of Components
8. Conditional Rendering
9. Modularization
10. Readability Rules
11. Self-Review Checklist

Applies equally to `.jsx` and `.tsx`. Where an example shows `.jsx`, the `.tsx` equivalent follows the same rule.

---

## 1. Structure

**Folders.** Small projects group by type: `components/` (reusable UI), `pages/` (one per route), `hooks/`, `services/` (API), `utils/` (pure helpers), `constants/`, `context/`. Larger projects group by feature:

```
src/
├── features/auth/{components,hooks,services}/ + authConstants.js + index.js (public API)
├── shared/{components,hooks,utils}/   # used by 2+ features
├── pages/
└── App.jsx
```

Deleting a feature folder should leave the rest of the app mostly intact. Code used by only one feature lives inside it.

**Component folders.** When a component has related files, give it a folder: `UserCard/{UserCard.jsx, UserCard.test.jsx, UserCard.module.css, index.js}`. The `index.js` (`export { default } from './UserCard'`) shortens imports.

**File order.** Use the same order in every component file:

```jsx
import { useState, useEffect } from 'react';      // 1. imports: external → internal → styles
import { useUser } from '../hooks/useUser';
import './UserCard.css';

const MAX_BIO_LENGTH = 120;                        // 2. constants (outside component)

function UserCard({ userId, onSelect }) {          // 3. component
  const { user, isLoading } = useUser(userId);     //    a. hooks
  const [isExpanded, setIsExpanded] = useState(false);
  const shortBio = user?.bio?.slice(0, MAX_BIO_LENGTH); // b. derived values (not state)
  useEffect(() => { document.title = user?.name ?? 'Loading...'; }, [user]); // c. effects
  const handleToggle = () => setIsExpanded((prev) => !prev);               // d. handlers
  if (isLoading) return <p>Loading...</p>;         //    e. early returns
  if (!user) return null;
  return <Card>...</Card>;                         //    f. JSX
}

export default UserCard;                           // 4. export
```

All hooks (including effects) must come before the early returns, since hooks can't be called conditionally.

**Keep components small.** Split when the file passes ~150–200 lines, the JSX has nameable sections, you're scrolling to follow it, one part re-renders much more than the rest, or you've copy-pasted JSX. The parent should read like a table of contents: `<DashboardHeader /> <StatsSummary /> <OrdersTable />`.

## 2. Component Basics

- **Presentational vs. logic.** Presentational components get everything through props and only render (`UserList`, `Button`). Logic components fetch data and manage state, then pass it down (`UserListPage`, `CheckoutContainer`).
- **Destructure props in the signature**, with defaults: `function Greeting({ name, count = 0 })`.
- **Prefer composition over prop overload.** Use `children` instead of `title`, `buttonText`, `buttonColor`, `icon`... props.
- **Slot props** for multiple regions: `<PageLayout header={<NavBar />} sidebar={<FilterPanel />}>{content}</PageLayout>`.
- **Controlled inputs** (`value` + `onChange`) for forms you validate; uncontrolled (`ref` + `defaultValue`) when you only read the value occasionally.
- **Stable keys.** Use `key={todo.id}`. Don't use `key={index}` for lists that can be added to, removed from, reordered, or filtered — React will mix up item state. Index keys are acceptable only for static lists that never change.

## 3. Object Lookups over Switch

When mapping one value to another value, component, function, or config, use an object instead of `switch` or `if/else` chains.

```jsx
const STATUS_COLORS = { success: 'green', warning: 'orange', error: 'red' };
const getStatusColor = (status) => STATUS_COLORS[status] ?? 'gray';

const NOTIFICATION_COMPONENTS = { success: SuccessAlert, error: ErrorAlert, info: InfoAlert };
const Component = NOTIFICATION_COMPONENTS[type]; // must be Capitalized for JSX
return Component ? <Component message={message} /> : null;

const ACTION_HANDLERS = {
  add: (state, payload) => [...state, payload],
  clear: () => [],
};
const handler = ACTION_HANDLERS[action.type];
return handler ? handler(state, action.payload) : state;

const BUTTON_VARIANTS = { primary: { color: 'primary', variant: 'contained' } };
<Button {...BUTTON_VARIANTS[kind]}>Save</Button>
```

Keep `switch`/`if` when conditions are ranges or complex expressions, branches run several statements, or there are only two cases (use a ternary).

Define lookup objects outside the component (or in `constants/`) so they aren't recreated each render.

## 4. Code Splitting

- **Routes** (most useful): `const HomePage = lazy(() => import('./pages/HomePage'));` wrapped in `<Suspense fallback={<PageSpinner />}>`. `lazy` requires a default export.
- **Heavy, rarely used components** (modals, charts): lazy-load and render inside `Suspense` only when shown.
- **Utility code:** `const { exportToPdf } = await import('../utils/pdfExport');`
- Wrap lazy content in an **Error Boundary** to handle load failures.
- **Split:** routes, modals, charts, rich text editors, admin sections. **Don't split:** small components visible on first load.

## 5. Naming

| Thing | Convention | Example |
|---|---|---|
| Components & their files | PascalCase | `UserProfile.jsx` |
| Hooks & their files | `use` + camelCase | `useAuth.js` |
| Functions / variables | camelCase | `formatPrice` |
| Util / service files | camelCase.js | `userService.js` |
| Constants & lookup objects | UPPER_SNAKE_CASE | `MAX_ITEMS`, `STATUS_COLORS` |
| Context / Provider | XContext / XProvider | `AuthContext`, `AuthProvider` |
| HOCs | `with` + Name | `withAuth` |
| Pages / Containers | XPage / XContainer | `LoginPage`, `TodoListContainer` |
| Tests / CSS modules | Name.test.jsx / Name.module.css | `UserCard.test.jsx` |

- **Booleans** start with `is`, `has`, `can`, `should`: `isLoading`, `hasErrors`, `canEdit`, `shouldShowBanner`.
- **Handlers:** `handleX` where defined, `onX` as props (`<TodoItem onDelete={handleDelete} />`).
- **State pairs:** `[user, setUser]`, `[isModalOpen, setIsModalOpen]`.
- **Functions start with a verb:** `fetchUsers`, `calculateTotal`, `validateEmail`.
- **Arrays plural, items singular:** `users.map((user) => ...)`.
- **Avoid** single letters (except loop vars and `(e) =>`), vague names (`data`, `info`, `temp`, `handleClick2`, `Component1`), and non-universal abbreviations (`usrLst` → `userList`).

## 6. Advanced Patterns

| Need | Pattern | Notes |
|---|---|---|
| Reuse stateful logic | Custom hook (modern default) | Hook returns `{ data, isLoading, error }`; component keeps only UI |
| Share data across many levels | Context + custom hook | Export `useAuth()` that throws if used outside the provider, so consumers never touch the context directly |
| Components used together | Compound components | `<Tabs><Tabs.Tab/><Tabs.Panel/></Tabs>` sharing state via context |
| Caller controls rendering | Render props (or a hook) | `render={(pos) => ...}` or function-as-children; mostly seen in libraries now |
| Same guard on many components | HOC (or wrapper component) | `withAuth(Page)`; set `displayName`. Hides prop origins and stacks badly, so prefer hooks in new code |
| Separate data from UI | Container/presentational (or a hook) | Container fetches; presentational renders and is easy to test with fake props |

**Rules of hooks:** call hooks only at the top level (not in conditions, loops, nested functions, or after an early return), and only from components or other hooks. In custom fetch hooks, check `res.ok` and abort with `AbortController` on cleanup.

## 7. Logic Out of Components

Components describe UI. Everything else goes elsewhere:

| Logic | Location |
|---|---|
| API calls | `services/` |
| Pure calculations / formatting | `utils/` (unit-testable) |
| Stateful logic (fetch + loading + error) | `hooks/` |
| Complex state transitions | `useReducer`, reducer in its own file |
| App-wide state | Context or a store (Redux/Zustand) |
| Validation | `utils/validation.js` or a schema |
| Magic numbers / strings | `constants/` |

Example split: `cartService.getCart()` → `cartCalculations.getOrderTotal(items)` (using `TAX_RATE`, `SHIPPING_COST` from constants) → `useCart()` returns `{ items, total }` → `Cart` renders `formatCurrency(total)`.

Use `useReducer` when several pieces of state change together or the next state depends on the action type. A `switch` is fine inside a reducer since each case builds new state; the lookup version (section 3) also works.

**State rules:**
- **Don't store what you can compute.** ``const fullName = `${first} ${last}`;`` — not state + effect.
- Keep state in the **lowest component** that needs it; lift only when siblings share it.
- **Don't copy props into state** unless it's deliberately an initial value (name it `initialX`).
- Use the **updater form** when new state depends on old: `setCount((prev) => prev + 1)`.
- **Never mutate:** `setItems([...items, newItem])`, not `items.push(...)`.

## 8. Conditional Rendering

| Situation | Use |
|---|---|
| Something or nothing | `&&` |
| A or B | Ternary (one level only, never nested) |
| Loading / error / empty | Early returns, keeping the happy-path JSX at the bottom |
| 3+ options from one value | Object lookup |
| Complex logic | Named variable or helper component |

- **`&&` with numbers renders `0`.** Use `items.length > 0 &&` or `Boolean(count) &&`.
- **Name complex conditions:** `const canSeeAdminPanel = user?.role === 'admin' && !user.isSuspended && settings.showAdminTools;`
- **Extract multi-branch logic** into a small component (`<StatusMessage status={status} />`).
- **Wrapper components for repeated guards**, e.g. `<RequireRole role="admin">`. Caution: children are evaluated even when the guard fails, so `<ShowIf condition={user}>{user.name}</ShowIf>` still crashes when `user` is null. Use wrappers only when the children don't depend on the condition being true; otherwise use `&&` or an early return.
- **Hide vs. unmount:** `{isOpen && <Modal />}` resets the modal's state each time; `hidden` / `display: none` keeps it. Choose deliberately.

## 9. Modularization

- **One job per file.** If describing it needs "and", split it.
- **Exports:** default for components (works with `lazy`); named for utils, hooks, services, constants. Pick a convention and stick to it.
- **Barrel files:** each feature's `index.js` is its public API. Import through it, never from another feature's internals. Avoid giant app-wide barrels (slow builds, circular imports).
- **Centralize the API layer:** one `httpClient(endpoint, { method, body })` that sets the base URL from env, JSON headers, and throws on `!response.ok`. Services wrap it (`getUsers = () => httpClient('/users')`). Components never call `fetch` directly.
- **Constants in one place**, e.g. ``ROUTES = { HOME: '/', PRODUCT_DETAILS: (id) => `/products/${id}` }``.
- **DRY, but not too early:** extract on the third repetition; don't build a 10-prop abstraction to merge two similar components.
- **Import order:** React & external libs → absolute/internal (`@/features/auth`) → relative → styles & assets.

## 10. Readability Rules

- **Small functions.** If one needs a comment explaining *what*, rename or split it. Comments explain *why*.
- **Keep comments short.** One line, two at most: a short description at the top of a file or component, or a brief *why* above a non-obvious line. No paragraphs, no multi-line explanations, no restating what the code already says. If it needs more, it belongs in the README or PR description.
- **No magic numbers or strings** (`MIN_PASSWORD_LENGTH`, not `8`).
- **Guard clauses** over deep nesting: `if (!user || !user.isValid) return;`
- Use optional chaining, nullish coalescing, destructuring, and template literals.
- **Keep JSX flat;** more than 3–4 levels of nesting means extract a component.
- **Never define components inside other components** (recreated each render, state lost).
- **Inline functions are fine.** Use `useCallback` / `useMemo` / `React.memo` only after measuring a real problem.
- **Effects are for syncing with outside systems** (APIs, subscriptions, timers, DOM), not for computing values or responding to user events.
- **Clean up effects that start something:** timers, subscriptions, event listeners, and fetches (abort them). One-off syncs like setting `document.title` don't need cleanup.
- Use a code formatter + ESLint with `eslint-plugin-react-hooks`.
- Consistency beats preference.
- Test logic (utils, hooks, reducers) and user-facing behavior with React Testing Library, not implementation details.

## 11. Self-Review Checklist

**Structure**
- [ ] Files in the right folder (component / hook / service / util / constant)
- [ ] File order: imports → constants → hooks → derived → effects → handlers → early returns → JSX → export
- [ ] No component over ~200 lines; big JSX sections extracted
- [ ] No components defined inside components

**Naming**
- [ ] Components & files PascalCase; hooks start with `use`
- [ ] Booleans `is` / `has` / `can` / `should`; handlers `handleX` / `onX`
- [ ] Constants UPPER_SNAKE_CASE; no vague names

**Logic & State**
- [ ] No `fetch` in components; API goes through `services/`
- [ ] Reusable stateful logic in hooks; pure calculations in `utils/`
- [ ] No derivable state; no mutation; state as low as possible
- [ ] Effects have correct deps and clean up what they start

**Conditionals & Lookups**
- [ ] Value-mapping `switch` / `if` chains replaced with lookups
- [ ] No nested ternaries; no number left of `&&`
- [ ] Early returns for loading / error / empty; complex conditions named

**Modularization & Performance**
- [ ] Routes lazy-loaded; heavy modals/charts lazy-loaded
- [ ] Constants, routes, config in `constants/`; no magic values
- [ ] Stable, unique list keys

**Readability**
- [ ] Each component understandable from its name and first few lines
- [ ] Comments explain why, and are short (one line, two at most)
- [ ] Formatted and lint-free
