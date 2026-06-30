# Note: Wiring Consumer rebuilds and frame triggering in Milestone 6

Story 5 (`task-5-5`) delivered a `Consumer` widget that reads providers at
compile time only. Several behaviors referenced by the Story 5 / Milestone 6
task files were intentionally deferred. This note describes exactly what is
missing and how to implement it, so the Milestone 6 work has a concrete plan.

## What Story 5 shipped

- `Consumer` (`lib/src/view/components/consumer.dart`) compiles
  `builder(context, ref)` into a single child element and delegates
  layout/paint to it.
- `WidgetRef` (`lib/src/view/widget_ref.dart`) exposes `read` and `watch`.
  Both currently delegate to `Context.read` → `ProviderContainer.read`.
  **No subscription is registered**, so provider changes do **not** rebuild.
- `ConsumerElement` is a transparent proxy `Element` with no `RenderObject`
  and no dirty-tracking.

## What Milestone 6 must add

### 1. `watch` must subscribe, like flutter_riverpod

Reference implementation: `ConsumerStatefulElement.watch` in
`flutter_riverpod` (`packages/flutter_riverpod/lib/src/core/consumer.dart`).

Pattern to replicate in `t22e`:

```
T watch<T>(provider) {
  // reuse existing subscription for this provider across one build pass
  final sub = _dependencies.putIfAbsent(provider, () {
    final previous = _oldDependencies?.remove(provider);
    if (previous != null) return previous;
    return context.container.listen(
      provider,
      (_, __) => markNeedsBuild(),   // <-- needs (2) and (3) below
    );
  });
  return sub.readSafe().valueOrProviderException as T;
}
```

Key points:
- Keep a `_dependencies` map keyed by `ProviderListenable`, so a provider
  watched once per build is not re-subscribed.
- On each build, swap `_dependencies` with an empty map, and close any
  subscription left in the previous map that was not re-watched this build.
  (`flutter_riverpod` calls this `_oldDependencies`.)
- Close all subscriptions on element unmount/dispose.

### 2. A `markNeedsBuild`-equivalent for elements

`t22e` has no `StatefulWidget`/`State`/`markNeedsBuild` yet (Milestone 5 only
shipped leaf and single-child render-object elements). Options, in order of
preference:

1. Introduce a minimal `StatefulWidget` / `State` / `StatefulElement` base
   (already listed in `NOTE-milestone-3-rework.md` as Milestone 5-owned but not
   yet implemented) with a `markNeedsBuild` that sets a dirty flag and requests
   a frame, then rebase `Consumer` on it — mirroring `flutter_riverpod` where
   `Consumer extends ConsumerWidget extends ConsumerStatefulWidget`.
2. If a full `StatefulWidget` is too large for one story, add just
   `markNeedsBuild` to the `Element` base class (dirty flag + frame callback)
   and call it from `ConsumerElement`.

Either way, `ConsumerElement` becomes the `WidgetRef` and the
stateful/dirty element at the same time, exactly as in `flutter_riverpod`.

### 3. Frame triggering without a scheduler

The project explicitly does **not** want a polling/scheduling frame loop.
Rebuilds must be triggered by reactive sources:

- **app context / provider change** — the `watch` subscription callback
  (`markNeedsBuild`) is the primary trigger.
- **widget context change** — future inherited-style data (theme, parent
  size) pushing a new `WidgetContext` down the tree.
- **MVVM** — ViewModel notifiers (API responses, user-interaction handlers)
  updating a provider the consumer watches.

Because there is no scheduler, the "frame request" must be a thin, injectable
callback. Recommended approach (no scheduler, no new central provider required):

- Add a `void Function() requestFrame` to `Context` (the app context).
- `markNeedsBuild` calls `context.requestFrame()`.
- The application wiring (`PipelineWidgetBinding` or a new app binding) sets
  `requestFrame` to a function that re-runs `renderWidget` once, batching
  multiple requests in the same event-loop turn (a simple `bool _dirty` /
  `scheduleMicrotask`) to avoid re-entrant builds.

This keeps the driver injectable and keeps `Pipeline` free of widget
knowledge, preserving the Milestone 3 layer boundary
(`tasks/milestone-5/NOTE-milestone-3-rework.md`).

### 4. Rebuild: recompile the subtree

Once `markNeedsBuild` fires, `ConsumerElement` must re-invoke
`builder(context, this)`, recompile the returned widget into a new child
element (`Widget.compile`), re-mount it, and replace the old child. Element
reuse (`Widget.canUpdate`) can stay deferred; a full recompile is acceptable
for the first phase and matches the deferred "selective element reuse" item
in `task-5-5.md`'s scope boundary.

## Related task files

- `task-5-5.md` — "A provider update triggers a new frame request and
  rebuild" (acceptance criterion deferred here).
- `task-6-1.md` / `task-6-1-3.md` — "Provider changes correctly trigger widget
  rebuilds via Consumer" and "Consumer rebuilds when the provider it watches
  changes".
- `task-6-3-2.md` — "feed a stdin event, request a frame, and verify the
  output changes".

## Suggested task breakdown for Milestone 6

1. Introduce `StatefulWidget` / `State` / `StatefulElement` (or a minimal
   `markNeedsBuild` on `Element`) — supports (2).
2. Add `requestFrame` to `Context` and wire a microtask-batched re-render in
   the app binding — supports (3).
3. Upgrade `ConsumerElement.watch` to subscribe via `container.listen` with a
   `markNeedsBuild` callback, manage `_dependencies`/`_oldDependencies`, close
   on dispose — supports (1) and (4).
4. Add rebuild tests: mutate a watched provider and assert the compiled
   subtree changes without a manual `compile` — satisfies `task-6-1-3` and
   the smoke test in `task-6-3-2`.