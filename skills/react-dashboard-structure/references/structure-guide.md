# React Dashboard Structure Guide

**Guiding principle:** The folder says what kind of code a file is; the file name says what it does. Anyone should be able to find a chart, a hook or an API call without searching.

All names below (`StatTile`, `GraphShell`, `ordersService` …) are placeholders for an example sales dashboard. Replace them with names from the real domain.

## Contents
1. Project Root
2. The `src/` Folders
3. Placement Table
4. Tie-Breakers
5. Naming and File Conventions
6. Example Tree
7. Self-Review Checklist

Applies equally to `.jsx` and `.tsx`. Where an example shows `.jsx`, the `.tsx` equivalent follows the same rule.

---

## 1. Project Root

```
<app>/
├── index.html
├── package.json
├── <build config>      # bundler and dev server settings
├── .env.example        # every env var the app reads, with safe sample values
├── <formatter config>  # shared formatting rules
└── src/
```

- Commit `.env.example`, never `.env.local`.
- Read env vars in one place (the HTTP client in `lib/`), not across the codebase.

## 2. The `src/` Folders

| Folder | What goes there | Shape |
|--------|-----------------|-------|
| `main.jsx`, `App.jsx`, `index.css` | Entry point, root component (providers + page), global styles and design tokens | Files at `src/` root |
| `pages/` | One folder per route or screen | `pages/<Name>Page/<Name>Page.jsx` + `.css` |
| `components/` | UI only, grouped by dashboard area | `components/<area>/<Component>/<Component>.jsx` |
| `context/` | State shared across distant components (applied filters, selections) | `context/<Name>Context.jsx` |
| `hooks/` | State and effect logic, one hook per file | `hooks/use<Thing>.js`, flat |
| `services/` | Data access, one file per resource | `services/<resource>Service.js`, flat |
| `lib/` | Thin wrappers around the outside world: the HTTP client, a charting or formatting library | `lib/<wrapper>.js`, flat |
| `utils/` | Pure functions: calculations, data shaping, layout math | `utils/<topic>.js`, flat |
| `constants/` | Lookup tables, config, option lists, default layouts, test data | `constants/<topic>.js`, flat |

### `components/` areas

Group components by the part of the dashboard they belong to, not by type. A typical dashboard has these areas:

| Area (example name) | Holds |
|---------------------|-------|
| `graphs/` | Reusable chart pieces: the chart frame (header, legend, tooltip, type switch), view renderers, table fallback |
| `board/` | The card grid and its cards, the expanded detail panels, the per-card error boundary, card-level toggles |
| `metrics/` | Single-number cards (value, change vs. last period, detail line) and their expanded view |
| `controls/` | Filters, split into primary (always visible) and advanced (behind a toggle) |
| `shell/` | App chrome: header, side menu, global buttons |

Add an area when a new dashboard part has three or more components. Until then, put the component in the closest existing area.

### Component folders

- Each top-level component gets its own folder named after it, holding `<Component>.jsx` and, if it has styles, `<Component>.css`.
- Sub-components used only by that component live in the same folder, prefixed with the parent's name: `GraphShell/GraphLegend.jsx`, `GraphShell/GraphTooltip.jsx`.
- When a component has many internal pieces of one kind, give them a subfolder: `GraphShell/renderers/ColumnView.jsx`, `GraphShell/renderers/paintColumns.js`.
- A constants file used only inside one component folder can live there (`GraphShell/graphKinds.js`). Move it to `constants/` once a second folder imports it.
- A folder that groups several small, related components with no styles of their own (e.g. `controls/QuickControls/` holding `DateWindowPicker.jsx` and `RegionPicker.jsx`) may share one area-level stylesheet: `controls/controls.css`.
- No `index.js` barrel files. Import the component file directly.

### The card → expanded panel pattern

- Each card type on the grid (`board/GraphTile`, `metrics/StatTile`) has a matching expanded view (`board/GraphDetail`, `metrics/StatDetail`).
- Expanded views share one generic shell (`board/DetailDrawer`) that owns opening, closing, focus and layout. Each expanded view only fills in its content.
- Wrap each card in a card-level error boundary (`board/TileFallback`), so one broken card doesn't blank the whole grid.

## 3. Placement Table

| The file… | Goes in |
|-----------|---------|
| Renders UI and wires up events | `components/<area>/<Component>/` |
| Is a whole screen or route | `pages/<Name>Page/` |
| Uses `useState`/`useEffect`/`useContext` to hold or load something | `hooks/use<Thing>.js` |
| Shares state with components far apart in the tree | `context/<Name>Context.jsx` |
| Requests data for one resource (orders, revenue, regions) | `services/<resource>Service.js` |
| Calls `fetch`, reads env vars, or wraps a third-party library | `lib/` |
| Is a pure function of its inputs (sorting, totals, chart scales, grid math) | `utils/<topic>.js` |
| Is a fixed value, lookup table, option list, default layout or mock data | `constants/<topic>.js` |

## 4. Tie-Breakers

- **Hook or util?** If it calls a React hook, it's a hook. Otherwise it's a util. Split mixed code: the hook calls the util.
- **Service or lib?** `lib/httpClient.js` is the only file that calls `fetch`. Services call the client and know about one resource's URL and parameters. `lib` knows nothing about the domain.
- **Context or hook?** Use context only when the state must be shared between components with no close common parent (sidebar filters → grid charts). Otherwise a hook in the nearest common parent is enough.
- **Component-local or shared?** Code starts next to the one component that uses it. Move it to the shared folder when a second component needs it.
- **Mock data:** while the API isn't ready, services return mock data from `constants/test<Thing>Data.js` (or a `.json` sample response), shaped like the real response. Components and hooks don't change when the real API lands.

## 5. Naming and File Conventions

| Kind | Case | Example |
|------|------|---------|
| Component file and folder | PascalCase | `StatTile/StatTile.jsx` |
| Page | PascalCase + `Page` | `OverviewPage/OverviewPage.jsx` |
| Context | PascalCase + `Context` | `QueryContext.jsx` (exports `QueryProvider` and `useQuery`) |
| Hook | `use` + camelCase | `useTileOrder.js` |
| Service | camelCase + `Service` | `ordersService.js` |
| Util, lib, constants files | camelCase | `currencyFormat.js`, `gridMath.js` |
| Exported constants | UPPER_SNAKE_CASE | `DEFAULT_TILE_ORDER` |
| CSS classes | kebab-case, prefixed with the component | `.stat-tile-header` |

- **Exports:** components use `export default function <Name>`. Hooks, services, utils and constants use named exports.
- **First line:** every file starts with a one-line comment saying what it is for.
- **Styles:** a component imports its own `.css` file as the last import. Global tokens live in `index.css`.
- **Import order:** React, then third-party packages, then project files (components, constants, context, hooks, lib, services, utils), then sibling files (`./`), then the stylesheet.

## 6. Example Tree

```
src/
├── main.jsx
├── App.jsx                         # providers + the page
├── index.css                       # global styles and design tokens
├── pages/
│   └── OverviewPage/
│       ├── OverviewPage.jsx
│       └── OverviewPage.css
├── components/
│   ├── graphs/
│   │   ├── GraphShell/
│   │   │   ├── GraphShell.jsx      # header, legend, tooltip, type switch around a view
│   │   │   ├── GraphShell.css
│   │   │   ├── GraphBody.jsx
│   │   │   ├── GraphLegend.jsx
│   │   │   ├── GraphTooltip.jsx
│   │   │   ├── GraphTable.jsx      # table view of the same data
│   │   │   ├── GraphKindSwitch.jsx
│   │   │   ├── graphKinds.js
│   │   │   └── renderers/
│   │   │       ├── ColumnView.jsx
│   │   │       ├── TrendView.jsx
│   │   │       ├── paintColumns.js
│   │   │       └── paintTrends.js
│   │   └── GraphPicker/
│   │       ├── GraphPicker.jsx     # chooses which view to render for a dataset
│   │       └── GraphPicker.css
│   ├── board/
│   │   ├── TileGrid/
│   │   ├── GraphTile/
│   │   ├── GraphDetail/            # expanded view of a GraphTile
│   │   ├── DetailDrawer/           # shared shell for every expanded view
│   │   ├── TileFallback/           # per-card error boundary
│   │   └── UnitToggle/
│   ├── metrics/
│   │   ├── StatTile/
│   │   │   ├── StatTile.jsx
│   │   │   ├── StatTile.css
│   │   │   ├── StatTrend.jsx
│   │   │   └── StatNotes.jsx
│   │   └── StatDetail/
│   ├── controls/
│   │   ├── controls.css            # shared by both control groups
│   │   ├── QuickControls/
│   │   │   ├── DateWindowPicker.jsx
│   │   │   └── RegionPicker.jsx
│   │   └── MoreControls/
│   │       ├── PriceBandPicker.jsx
│   │       └── ChannelPicker.jsx
│   └── shell/
│       ├── TopBar/
│       └── NavRail/
├── context/
│   └── QueryContext.jsx
├── hooks/
│   ├── useOrders.js
│   ├── useAbortableRequest.js
│   ├── useTileOrder.js
│   └── useElementWidth.js
├── services/
│   ├── ordersService.js
│   └── revenueService.js
├── lib/
│   ├── httpClient.js               # the only file that calls fetch()
│   └── currencyFormat.js
├── utils/
│   ├── gridMath.js
│   ├── tileOrder.js
│   └── dateWindows.js
└── constants/
    ├── defaultTileOrder.js
    ├── regions.js
    ├── unitModes.js
    └── testOrdersData.js
```

## 7. Self-Review Checklist

**Folders**
- [ ] Each file is in the folder the placement table (§3) gives it
- [ ] Components grouped by dashboard area, one folder per top-level component
- [ ] Sub-components sit beside their parent, prefixed with its name
- [ ] No `index.js` barrel files

**Data**
- [ ] Only `lib/httpClient.js` calls `fetch` and reads env vars
- [ ] One service file per resource; mock data in `constants/`, shaped like the real response
- [ ] Context used only for state shared between distant components

**Cards and Panels**
- [ ] Every card type has a matching expanded view
- [ ] Expanded views share one panel shell
- [ ] Every card is wrapped in a card-level error boundary

**Naming and Files**
- [ ] File and folder names follow §5 (PascalCase components, `use` hooks, `Service` suffix, camelCase helpers)
- [ ] Every file starts with a one-line purpose comment
- [ ] Each component imports its own stylesheet last
- [ ] Names come from the real domain, not this guide's placeholders
