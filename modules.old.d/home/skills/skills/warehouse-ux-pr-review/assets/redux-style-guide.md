# Redux Style Guide (mirror)

Mirrored from <https://redux.js.org/style-guide/style-guide> for offline
reference inside this skill. Treat the upstream page as the source of
truth; this copy may drift.

---

## Rule categories

- **Priority A — Essential.** Prevent errors. Abide by these at all costs.
- **Priority B — Strongly Recommended.** Improve readability / DX. Follow
  whenever reasonably possible.
- **Priority C — Recommended.** Pick a default for consistency.

---

## Priority A: Essential

### Do Not Mutate State

Mutating state is the most common cause of bugs in Redux apps. It breaks
re-renders and time-travel debugging. Use Immer (and RTK, which bundles
it) to write "mutating" syntax over an immutable target. Tools like
`redux-immutable-state-invariant` catch mutations during development.

### Reducers Must Not Have Side Effects

Reducers depend only on `state` and `action`. No AJAX, no timeouts, no
promises, no `Date.now()` / `Math.random()`, no mutation of outside
variables. They must be pure so they can be replayed for time-travel
debugging.

### Do Not Put Non-Serializable Values in State or Actions

No Promises, Symbols, Maps/Sets, functions, or class instances in the
store or in actions. Exception: middleware (thunks, redux-promise) may
intercept non-serializable actions before they reach the reducer.

### Only One Redux Store Per App

One store per app, defined in its own file (e.g. `store.ts`). App logic
should not import the store directly — pass it via `<Provider>` or via
middleware (thunks). Direct imports are a last resort.

---

## Priority B: Strongly Recommended

### Use Redux Toolkit for Writing Redux Logic

RTK bakes in good defaults: store setup that catches mutations, DevTools
wiring, Immer-based reducers, `createSlice`, etc.

### Use Immer for Writing Immutable Updates

Immer lets you write "mutating" reducer code that produces immutable
results, and freezes state in dev to catch mutations elsewhere.

### Structure Files as Feature Folders with Single-File Logic

Use feature folders ("ducks" pattern). Each feature gets one slice file
(`createSlice`) co-located with its component(s).

```
/src
  /app          # store, root reducer, App.tsx
  /common       # generic utils/components/hooks
  /features
    /todos
      todosSlice.ts
      Todos.tsx
```

### Put as Much Logic as Possible in Reducers

Reducers are pure and trivially testable. Doing state math in reducers
makes more of your logic testable, avoids accidental mutations from
outside-the-reducer derivations, and keeps the update logic in one place.
Generating an ID before dispatch is fine; reshaping arrays in the click
handler is not.

### Reducers Should Own the State Shape

Each slice reducer owns the initial value and every update to its slice.
**Minimize blind spreads/returns** (`return action.payload`,
`return {...state, ...action.payload}`). Those hand state-shape control
to the dispatcher. Strong typing (`PayloadAction<User>`) makes spread
returns safer when you do use them.

### Name State Slices Based On the Stored Data

`{ users, posts }`, not `{ usersReducer, postsReducer }`. Use explicit
`key: value` syntax in `combineReducers` to avoid the
`{ usersReducer }` shorthand trap.

### Organize State Structure Based on Data Types, Not Components

State is a global database; components are views over it. Name slices
after data (`{ auth, posts, users, ui }`), not screens
(`{ loginScreen, usersList, postsList }`).

### Treat Reducers as State Machines

Reducer behavior should depend on both current state and action, not the
action alone. Use explicit `status: "idle" | "loading" | "success" |
"failure"` finite-state fields; with TypeScript, model each state as a
member of a discriminated union so impossible combinations
(`status: "success"` with `error: Error`) can't be constructed. Consider
writing a sub-reducer per state ("finite state reducers") that gates
which actions are valid in that state.

### Normalize Complex Nested/Relational State

Cache server data in normalized form (lookup by ID), not nested. Easier
updates, better performance, fewer bugs.

### Keep State Minimal and Derive Additional Values

Store the minimum; derive the rest. Filtered lists, totals, "is all
done?" — derive in selectors (memoize with `reselect` or
`proxy-memoize`). The base state stays small and readable.

### Model Actions as Events, Not Setters

Prefer `"food/orderAdded"` over `"orders/setPizzasOrdered"`. Events
describe what happened; setters bake the state shape and the new value
into the dispatcher. Events lead to fewer, more meaningful actions and a
more useful DevTools log.

### Write Meaningful Action Names

`type` matters to you, not Redux. Read the action log as a story.
Replace `"SET_DATA"` / `"UPDATE_STORE"` with names that describe what
happened.

### Allow Many Reducers to Respond to the Same Action

Reducers compose. One dispatched action may legitimately update several
slices. This usually means fewer dispatches and a codebase that scales.

### Avoid Dispatching Many Actions Sequentially

Multiple dispatches → multiple subscription callbacks → multiple UI
updates and possibly invalid intermediate states. Prefer one event-style
action that triggers all the updates. If you must dispatch many, batch
them (`batch()` from React-Redux, debouncing, or a single coarser
action).

### Evaluate Where Each Piece of State Should Live

"Global state" doesn't mean "every value". Truly app-wide values go in
Redux; local UI values stay in component state.

### Use the React-Redux Hooks API

`useSelector` / `useDispatch` are the default. Less indirection, simpler
TypeScript, easier composition than `connect`. `connect` still works.

### Connect More Components to Read Data from the Store

Subscribe granularly. `<UserList>` reads ids; `<UserListItem userId>`
reads its own user. Fewer renders per state change.

### Use the Object Shorthand Form of `mapDispatch` with `connect`

If you do use `connect`, write `mapDispatch` as an object of action
creators.

### Call `useSelector` Multiple Times in Function Components

Many small selectors > one fat selector returning an object. Smaller
slices mean fewer renders. Balance: if you really need every field,
just take the slice.

### Use Static Typing

TypeScript (or Flow). RTK is written in TS and is designed for minimal
extra type annotations.

### Use the Redux DevTools Extension for Debugging

Action log, action contents, post-action state, state diff, dispatch
stack trace, time-travel. The DevTools are a primary reason to use
Redux.

### Use Plain JavaScript Objects for State

Plain objects + Immer. Immutable.js's API "infects" your code, has a
large bundle, expensive conversions, and is largely unmaintained.

---

## Priority C: Recommended

### Write Action Types as `domain/eventName`

`"todos/addTodo"`, not `"ADD_TODO"`. RTK's `createSlice` generates this
shape by default.

### Write Actions Using the Flux Standard Action Convention

`{ type, payload, meta?, error? }`. RTK's action creators are FSA.

### Use Action Creators

Don't dispatch object literals everywhere. Use `createSlice` to generate
both the type and the creator.

### Use RTK Query for Data Fetching

Fetching + caching is the most common side-effect. RTK Query handles
dedup, caching, lifecycle, component updates. Prefer it over hand-rolled
data fetching.

### Use Thunks and Listeners for Other Async Logic

- **Thunks** (`redux-thunk`) for imperative async/sync logic that needs
  `dispatch` / `getState`.
- **Listener middleware** (`createListenerMiddleware`) for reactive
  logic that responds to actions or state changes — long-running
  workflows, background behavior.
- Avoid Saga / Observable unless nothing simpler works.

### Move Complex Logic Outside Components

Especially logic that reads from store state. Thunks are the usual
landing spot. Hooks can sometimes replace the thunk if the logic only
serves one component.

### Use Selector Functions to Read from Store State

Encapsulate reads in selectors, memoize with Reselect when the
computation is non-trivial. Don't manufacture a selector for every
single field.

### Name Selector Functions as `selectThing`

`selectTodos`, `selectVisibleTodos`, `selectTodoById`.

### Avoid Putting Form State In Redux

In-progress form state is local, not global, not cached, not shared.
Dispatching on every keystroke costs performance for nothing. Keep
edits in component state; dispatch once on submit. Live previews and
similar cross-component cases are the rare exception.

---

## Source

- <https://redux.js.org/style-guide/style-guide>
