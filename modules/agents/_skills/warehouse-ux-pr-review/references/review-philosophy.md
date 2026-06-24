# Miles' code review philosophy (TridentWarehouse-UX)

Distilled from ~1,150 of my comments across 482 PRs in
`dev.azure.com/powerbi/Trident/_git/TridentWarehouse-UX` over the last year.
This is descriptive, not prescriptive — it describes how I actually review,
so an agent can imitate the lens I use when reading a PR.

---

## 0. Gestalt

These are the themes underneath every specific rule in this document.
The agent should treat them as the *why* — when section 3's rules and
section 0's themes both point at a comment, that comment is high
confidence. When a candidate violates a section 3 rule but the
violation actually *serves* one of these themes, surface that tension
instead of the rule.

### 0a. Simplicity, in the Rich Hickey sense

By "simple" I do **not** mean "easy", "small", or "few lines". I mean
[*simple* as opposed to *complex*][hickey] — un-braided. A simple thing
does one thing, holds one concern, and is not woven together with other
things. Complexity is the count of independent concerns *braided* into
one piece of code.

[hickey]: https://www.infoq.com/presentations/Simple-Made-Easy/

When I read code, I'm asking: **how many things are woven together
here, technically and philosophically?** Each of these is a strand
that, if added, makes the code more complex (more braided), regardless
of how few lines it took:

- Reaching into another feature's components, hooks, or selectors
  (braids feature A with feature B).
- Reading from a global store inside a leaf component or utility
  (braids the function with the store, the slice shape, and the
  current app state).
- Mixing client and server state in the same shape (braids the
  server's domain model with view-only flags — now neither model is
  trustworthy).
- A component that fetches, transforms, and renders (braids IO,
  business logic, and presentation).
- Optional fields, runtime guards, and `as` casts that exist only to
  paper over a type that's modeling two different things (braids
  multiple cases into one type).
- Environmental dependencies — `store.getState`, `Date.now`,
  `process.env`, ambient singletons — that mean the function's output
  depends on more than its inputs (braids the function with its
  environment).

Concrete shapes I push toward as a result:

- **A "presenter" component wherever possible** — a component whose
  inputs are explicit props and whose output is markup, with no
  `useSelector`, no `useDispatch`, no http, no router. The
  surrounding container does the braiding; the presenter stays
  simple, reusable, and trivially testable.
- **Abstraction, not sharing, between features.** If
  `WarehouseSnapshots` and `InPlaceRestore` both need the same
  capability, extract the simple shared *concept* (a component, a
  type, a utility) into a neutral home — don't have one feature
  import from the other. Sharing braids the two features together;
  abstraction keeps them independent.
- **Separate client state from server state.** Same slice is fine,
  but each gets its own sub-domain (see section 3a). Server-shaped
  records stay server-shaped; view concerns live next to them, not
  inside them.
- **Functions that take what they need.** If a function reads from
  the store, pass it the value instead. If it reads the current
  artifact, pass it the artifact. The function becomes
  context-independent and the call sites become honest about what
  they depend on.

When evaluating a change, the simplicity question to ask is: *does
this PR add a strand, or remove one?*

### 0b. Code should build its own correctness

I want code that **makes its constraints intrinsic** — the type
system, the function signature, and the module boundary should make
incorrect usage either impossible or obviously wrong. Correctness
should not live in a comment, a convention, a README, or a reviewer's
memory.

What this looks like in practice:

- **Types that make illegal states unrepresentable.** Discriminated
  unions instead of "this field is set when status is X". `readonly`
  arrays when callers shouldn't mutate. Required fields instead of
  optional + runtime guard. If an `as` cast is needed for an internal
  type we control, the type is wrong — fix the type, not the call
  site.
- **Functional / referentially-transparent code where possible.**
  Pure functions, immutable data, derivations over mutations. A
  function whose output depends only on its inputs is a function I
  can reason about; a function that reads ambient state is one I
  have to *trace*.
- **Module surfaces that enforce their own use.** Exports that take
  exactly what they need, in the shape they need it. No "the caller
  must remember to dispatch X first" — encode that as the parameter
  the function takes.
- **No external semantics if avoidable.** "This boolean means the
  user clicked submit *and* we're not loading *and* the artifact is
  ready" is a semantic that should be a single named state, not three
  conditions reassembled at every call site.

When evaluating a change, the correctness question to ask is: *can the
caller misuse this in a way the type system or signature won't catch?*

### 0c. We are mid-migration. Be constructive about it.

This codebase has accumulated a lot of anti-patterns over time, and
the average technical level of the team varies. I read most PRs with
the understanding that I'm partly **fighting for the soul of this
app** — pulling architecture toward something more coherent over many
PRs and many quarters. There are several *transitory* patterns in
flight at any moment:

- The "currently selected artifact" pattern is being removed; new
  usages create future work.
- Fluent UI v8 → v9 migration is ongoing.
- `DialogManager` is being phased out in favor of the extension
  client's platform dialog API.
- `App.tsx` is bloated and we're trying to stop adding to it.
- `store.getState` / `store.dispatch` / singleton service imports
  outside `index.*.ts` are legacy; new instances shouldn't be added
  even when surrounded by existing ones. Cross-cutting concerns
  (logging, http, telemetry, time) should be moving toward DI via
  thunk-extra / epic dependencies.
- Many existing epics are oversized; we're moving toward thunks for
  simple cases and chained, single-purpose epics for the rest.
- Established features have a lot of *local* client state in Redux
  for historical reasons; new features should keep local-only state
  in component state.
- The push toward presenter components, away from "smart" components
  with embedded data dependencies, is ongoing.

This context shapes how the agent should produce candidates:

- **Be constructive.** The goal is to elevate, not to grade. A
  candidate that explains *why* the pattern is being moved away from
  is more useful than one that just says "don't do this".
- **Don't penalize touching legacy code for moving it slightly.** If
  a PR refactors a file that already had three `store.getState`
  calls and adds a fourth, surface the new one — but note the
  pre-existing context. Don't ask the author to fix the file's
  pre-existing problems.
- **Track recurring violations.** When the same anti-pattern shows
  up across multiple PRs from the same area, that's signal — surface
  it explicitly so I can decide whether to escalate beyond a comment
  (a docs change, an ADL, a sync with the area lead).
- **Recognize the long arc.** Some comments exist to plant a flag
  ("this is something to come back to") rather than to demand a
  change in this PR. The agent should be willing to draft those
  flag-planting comments and tag them as `suggest` or `concern`, not
  `blocking`.

---

## 1. The lens

A review is a conversation about whether the change makes the codebase
**simpler (§0a), more self-correcting (§0b), and easier to change
tomorrow** — not whether it "works". I usually accept that the code
works. What I want to know is:

- Does this change put logic in the **right architectural layer**?
- Does it leak concerns across layers (component knows about data source,
  http knows about components, store knows about navigation, etc.)?
- Does it create a **future cleanup task** for someone else?
- Does it use the **type system to make illegal states unrepresentable**,
  or does it lean on `as`, optional fields, and runtime guards?
- Does it match the **established patterns** in this codebase — and if it
  invents a new one, is the new one actually better?
- Is this change pulling us *toward* the architecture we're migrating
  to, or *deeper into* a pattern we're trying to leave?

If the change is good architecturally, I'll forgive a lot of style.
If the change works but pushes the architecture in the wrong direction,
I'll push back even when the code is small.

---

## 2. Tone

- **Default to questions, not commands.** "Could we…", "Why…", "What
  happens if…", "Is there a reason…". A question invites the author to
  defend the choice; a command shuts the conversation down. I only switch
  to imperatives ("Don't use `store.getState` here", "Move this to the
  app side") for things I've already explained before, or for clear
  architectural rules.
- **Label severity explicitly.** `Nit:`, `(nit)`, `Style nit:`, `n/a:`,
  `Just a thought`, `feel free to close after reading`, `no need to change,
  commenting for awareness`. The author should always know whether a
  comment is blocking, optional, or just FYI.
- **Be warm.** `:trophy:`, `:crown:`, `helllllllll yeaaaaaah`, `So nice!!!`,
  `Great work!`, `thank you SO MUCH for doing this :pray:`. Praise good
  work as loudly as you criticize bad work — louder, ideally.
- **Disagree without flattening.** "Hate to disagree here, but…",
  "I'm starting to wonder if I'm being too dogmatic", "philosophy probably
  shouldn't block reality". Be willing to walk back your own position
  in-thread when the author makes a good point.
- **Never sneer.** "Dear god, this cannot be how we exclude things from
  the OE :sob:" is about the *code situation*, not the author.
- **Acknowledge what isn't theirs.** "So this isn't you, but just for
  visibility…", "I know you're just refactoring these, but…", "I know it
  was in there incorrectly when you got here". Don't make people defend
  pre-existing code they happened to touch.

---

## 3. The architectural rules I actually enforce

These are the patterns I push on hardest, in roughly descending frequency:

### 3a. Redux / state management

- **Reducers own the shape of the state.** Each reducer is responsible
  for defining and maintaining the structure of its slice. The shape
  is not negotiated with the dispatcher and not derived elsewhere. The
  failure mode to watch for is the **catch-all setter action** — a
  single `setFoo` / `updateState` / `setData` reducer that takes
  whatever payload it's given and merges it in (`return action.payload`,
  `return {...state, ...action.payload}`). That hands shape ownership
  to every call site and makes the slice's actual shape impossible to
  reason about from the reducer alone. Prefer event-style actions
  (§0a, "Model Actions as Events" in the Redux style guide) that
  describe what happened and let the reducer decide what fields to
  update.
- **Slices are domain-oriented, not screen-oriented.** Name and shape
  the slice after the underlying domain or backend API, not after the
  page that consumes it (`warehouseSnapshots`, not `manageSnapshotShell`).
  If the server exposes `GET /warehouses/:id/snapshots → Snapshot[]`,
  the slice should hold `Snapshot` records in the same shape the API
  returns them — that way the reducer is doing translation work *once*
  at the boundary, and selectors / components see a stable, server-shaped
  model. If the slice diverges from the API, there should be a clear
  reason in the diff.
- **Do not mix client state and server state in the same shape.** They
  can live in the same slice (often should, for locality), but they
  must occupy their own sub-domain. The server-cached entities go in
  an entity adapter (`createEntityAdapter` → `{ ids, entities }`); the
  client-side concerns (selection, filters, view mode, "is this row
  expanded", request status) go in sibling fields. Never widen the
  server entity type with view-only fields like `isSelected`,
  `isExpanded`, `isEditing` — that's a category error and it makes the
  cached server data lie about what the server said.

  Rough template:

  ```ts
  const snapshotsAdapter = createEntityAdapter<WarehouseSnapshot>();

  interface WarehouseSnapshotsState {
    // server-cached domain
    snapshots: EntityState<WarehouseSnapshot>;
    requestStatus: "idle" | "loading" | "success" | "failure";
    // client / view concerns — explicitly separated
    selection: { selectedId?: string; multiSelectIds: string[] };
    ui: { isCreateDialogOpen: boolean };
  }
  ```

- **Normalize server data with `createEntityAdapter`.** Nested or
  relational payloads get flattened to `{ ids, entities }` at the
  reducer boundary. Lookups become O(1), updates are local, and the
  adapter's selectors compose cleanly with `reselect`.
- **Epics are for IO and side-effects**, not for owning default state
  and not for navigation when a component could do it more naturally.
- **Prefer async thunks over epics for simple cases.** If an epic
  exists only to map one action → one IO call → one success/failure
  action, it should be a `createAsyncThunk`. Reach for an epic when
  the flow is genuinely *reactive* (multi-stream composition,
  cancellation, debouncing, long-lived subscriptions). New "trivial"
  epics are a candidate for a thunk rewrite suggestion.
- **One epic should do one thing.** A growing epic that fetches *and*
  transforms *and* navigates *and* dispatches three follow-ups is a
  smell. Decompose by emitting intermediate actions and having
  separate epics listen for them — `actionA → epic1 → actionB → epic2
  → actionC`. The chain is observable in the action log, each epic
  becomes testable in isolation, and other features can plug into
  any link in the chain.
- **Cross-cutting concerns belong in epic dependencies, not in
  imports.** Logging, http clients, telemetry, time, navigation, and
  similar ambient capabilities should be injected via the epic's
  dependencies object (`thunkExtra` / `EpicDependencies`), not
  imported as singletons at the top of the file. This is the DI
  pattern we are moving toward in both redux-observable and
  redux-thunk. A new direct import of `logger` / `httpClient` /
  `extensionStore` from inside an epic or thunk body is a candidate
  for refactor to dependency injection.
- **No singleton access.** `store.getState`, `store.dispatch`,
  `extensionStore.extensionClient.*` reached from arbitrary modules,
  ambient module-level service caches, mutable top-level `let`s —
  all of these are singletons in disguise and braid the function
  with global state (§0a). The acceptable places are `index.*.ts`
  files at composition time and the epic-dependency object. Flag
  every new instance, even in refactors that merely move them
  around.
- **`useDispatch` from components**; **return actions from epics.**
- **Don't depend on the "currently selected artifact"** in
  epics/selectors unless you have to — take `artifactId` /
  `workspaceId` on the action payload instead. This pattern is being
  removed; new usages create future work.
- **Model actions as events, not requests.** `inPlaceRestorePageOpened`
  beats `fetchRetentionPeriodAndListRestorePoints`. The view says "I'm
  here", the store decides what that means. (Mention `listenerMiddleware`
  / `createListenerMiddleware` when it fits.)
- **Be careful putting client state in Redux, especially in newer
  features.** Redux is for state that needs to be observed across
  features or that must outlive the component tree. If the state is
  purely local to one component / one feature ("is this dialog
  open", "what's in this search box", "which tab is active in this
  one panel"), it belongs in `useState` / `useReducer`, not in a
  slice. The argument for promoting client state to Redux is *other
  features need to observe it* — if that's true, fine; if not, push
  back. Established features have a lot of legacy client state in
  Redux for historical reasons; don't make it worse in new features.
- **Memoize selectors that are created per-render.** A bare
  `createSelector(...)` inside a component re-creates the selector
  and defeats memoization; either hoist it, wrap in `useMemo`, or
  use a curried selector pattern.
- **Don't throw in epics for valid empty cases.** Return `EMPTY`,
  `of([])`, etc.

### 3b. Typescript

- **Type assertions (`as`) are a smell.** If you need one for an internal
  type you control, the type is wrong — fix the type. Reach for
  **discriminated unions** (`$type` / kind fields), **type predicates**,
  or **literal action-type second-parameter inference**
  (`createAction<Payload, "name">(...)`).
- **Don't make fields optional just to satisfy an upstream optional.**
  Handle the optionality at the boundary; make the inner type require
  what it actually needs.
- **Prefer `readonly` arrays** for return types that callers shouldn't
  mutate.
- **Don't use the namespace name for type compatibility** — TS is
  structural.

### 3c. Module boundaries and separation of concerns

The driving idea: **no leaky APIs, no crosstalk between sibling
modules.** Each feature/domain/module owns its own surface, depends
only on shared primitives, and stays ignorant of its peers.

- **Features don't reach into other features.** A *feature* is the unit
  of cross-cutting work in this codebase — `InPlaceRestore`,
  `WarehouseSnapshots`, `Migration`, `QueryActivity`, `CopilotSidecar`,
  `SecurityMode`, etc. Each lives in its own folder under
  `components/`, `store/`, and friends. Feature A must not import
  components, hooks, selectors, action creators, or types from feature
  B. If `WarehouseSnapshots` is reaching into `InPlaceRestore` (or vice
  versa), the shared concept needs to be *extracted* to a shared
  module — not borrowed across.
- **Module boundaries are real, not aspirational.** Watch the import
  graph for arrows that should not exist:
  - `http/` importing from `components/`
  - `store/<featureA>/` importing from `components/<featureB>/`
  - `packages/relational-db-ux` importing from `apps/extension-app`
  - a feature folder importing a *sibling* feature folder
  - a shared/common module importing a specific feature
  Any of these is the comment.
- **Types belong with their producer, not their consumer.** If a type
  is used by `http/getWarehouseSnapshot.ts`, it lives near http (or
  in a shared types module) — *not* in a component folder that
  happens to be the first place it was needed. Otherwise http ends up
  depending on components, which is backwards.
- **Selectors live as high as the data does.** Page-level selectors
  pass data down. A leaf component should not select its own data from
  the store unless that data is genuinely shared and lookup-by-id; the
  moment a component selects from a feature-specific slice, that
  component is welded to that data source and can't be reused.
- **Don't grow component interfaces for every new feature.** When a
  shared component (toolbar, dialog, data grid) needs new behavior,
  prefer `children` / `React.PropsWithChildren` / render props over
  adding `actionsLeft`, `actionsRight`, `extraItems`, `mode`,
  `variant`, etc. New props per consumer is the symptom of leaking
  consumer concerns into a shared module.
- **Prefer fluent-ui v9 over v8**, and don't mix versions inside one
  feature — mixing versions is a form of internal API leak (component
  behavior now depends on which fluent version it was wired against).
  Use the v9 API names (`DialogActions`, not the v8 footer pattern).
  When pushed back, ask *what specifically* v9 can't do.
- **Avoid new `DialogManager` calls — use platform dialogs.** The
  in-app `DialogManager` is legacy; new dialog needs should go through
  the extension client's platform dialog API. Existing `DialogManager`
  usages are tolerated, but every *new* call site is a candidate for
  a "use the platform dialog API instead" comment.
- **Lift one-time / app-wide logic out of `App.tsx` / `Container`
  hooks.** `App.tsx` runs in a render loop and double-runs under
  strict mode in dev. Things that should run once on app start
  (extension client init, deep-link decoding, service registration)
  belong in `index.ui.tsx` or in a context provider that owns that
  lifetime — not in a component that re-renders.

### 3d. Tests

- **A test that mocks the function under test is circular.** If the only
  un-mocked code is the helper you also use to build the expected value,
  the test passes for any implementation — show a "replace body with
  `return [{ fakeDate: "test" }]` and this still passes" counter-example.
- **Mock at the selector boundary, not at deep internals.** Selector
  mocks survive refactors; structural mocks don't.
- **Cleanup in `beforeEach`, not `afterEach`.** Don't assume other tests
  cleaned up after themselves.
- **Global test setup belongs in global test setup**, not in one file
  where it bleeds into every test that runs after it.

### 3e. Performance / data structures

- Call out `O(n²)` / `O(m·n)` / `O(n log n)` when a `Set`, `Record`, or
  single `map` would drop a term. Use math notation: `$O(n)$`,
  `$O(n \log n)$`.
- Flag `lodash` whole-package imports — use named imports
  (`import { isNil } from "lodash-es"`) for bundle size.
- Flag re-computation in render that should be memoized.

### 3f. RxJS / epics

- `map` over `mergeMap` when you can map `T → U` instead of `T → M<U>`.
- Warn against naming non-stream values with `$` suffix — it's reserved
  for observables in this codebase.
- Suggest `concatMap` + `throttleTime` over `mergeMap` when the user can
  spam the trigger.
- Suggest `concat(of(action1), of(action2), epic$)` to sequence
  pre-actions before an inner epic stream.

### 3g. Naming / clarity

- **Generic names ("upgradeBatch", "state$", "data") that are really
  something specific** get flagged.
- **Magic strings** get flagged ("Ditto magic string").
- Prefer extracting URLs / constants to named bindings.

---

## 4. Recurring move set

These are the specific "moves" I tend to make in reviews. The agent
should draft comments in these shapes; **whether to actually leave a
given comment is my call, not the agent's.** Surface the candidate, the
evidence, and the suggested shape — let me pick.

1. **Ask a clarifying question** ("Are these related to the current
   artifact?", "What does this do?", "Why do we need this?") instead of
   asserting a problem. ~25% of comments.
2. **Suggest a refactor with a `suggestion` code block** showing the
   exact replacement. When the change is non-trivial I include the
   "before / after" or "function F / function G" abstraction.
3. **Mark a nit and explicitly say "feel free to close after reading"**
   for things worth recording but not blocking.
4. **Open a follow-up loop**: "no need to change in this PR, but make
   yourself a work item to come back to this".
5. **Teach with a link** to MDN / TS handbook / fluent-ui storybook /
   Redux style guide, rather than just asserting the rule.
6. **Show my own work**. When the answer requires evidence (render
   counts, type behavior, time-zone parsing) include the script /
   table / screenshot used to convince oneself.
7. **Flag scope creep** — "This is a file I'd actually like us to stop
   updating unless *absolutely* necessary".

---

## 5. Heuristics for an agent producing review suggestions

The agent's job is to **propose candidate comments and the evidence
behind them**, not to post anything and not to decide what's worth
enforcing. For every PR:

1. **Read the diff for architectural posture first**, line-level second.
   Where does each new piece of logic live? Is that the right layer?
2. **For every new line of code, ask:** does this couple two things that
   were previously independent? (feature ↔ sibling feature, http ↔
   component, store ↔ navigation, package ↔ app, type ↔ caller-state.)
3. **For every `as`, optional field, or runtime nil-guard:** can the
   type system express this directly?
4. **For every new `store.getState` / `store.dispatch`** outside an
   `index.*.ts`: flag as a candidate.
5. **For every new selector created inline:** check memoization.
6. **For every test:** check whether it could pass against a stub
   implementation. If yes, draft the counter-example.
7. **For every loop / lookup:** check the complexity. If it's worse
   than it needs to be and the fix is small, draft the `Set` / `Record`
   suggestion.
8. **For every new slice / reducer / entity adapter:** check section
   3a — domain shape, client-vs-server separation, no blind spreads.

For each candidate the agent surfaces, include:

- **What** the candidate is about (one line).
- **Where** to look: `file:line` references (prefer the format from
  this repo's `AGENTS.md`) and, when relevant, links to peer files
  that are evidence of the pattern or counter-pattern.
- **Why** it's a candidate — which rule from section 3 applies.
- **A draft comment** in the tone of section 4, ready to copy/paste
  or refine.
- **Severity tag**: `question` / `nit` / `suggest` / `concern` /
  `praise`. (These are hints to me; I decide whether to leave the
  comment and at what severity.)

Group candidates by file. Don't post anything. Don't filter for me
based on "is this worth blocking on" — surface the candidate and let
me decide.
