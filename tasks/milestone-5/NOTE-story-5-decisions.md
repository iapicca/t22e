# Note: Story 5 (Consumer Widget) — decisions and scope updates

This note records the design decisions taken while implementing Story 5
(`task-5-5`) and how they deviate from or clarify the original task files.

## Context split: a single "app context" for now

The story files define `TuiContext` (task-5-4) as the object that carries
provider access through the build pass. We agreed to rename `TuiContext` to
just `Context` and keep a **single context class** for this milestone rather
than splitting it into an "app context" and a "widget context" up front.

- `lib/src/view/context.dart` now holds the `ProviderContainer` and exposes
  `T read<T>(ProviderListenable<T> provider)`.
- This is the **app context**: it is shared across the whole tree and gives
  widgets access to Riverpod providers.

A future split is intentionally left open: when tree-local data (parent
constraints, theme, inherited style) needs to flow down the tree, a separate
*widget context* (analogous to Flutter's `BuildContext`) can be introduced
either as an additional `compile` parameter or as a field on `Context`. No
existing `compile` signature changes will be required for app-context reads.

## Consumer API: follow flutter_riverpod's WidgetRef model

The original `task-5-5-1` describes a `Consumer<T>` that takes a single
`ProviderListenable<T>` and a `(Context, T) => Widget` builder. We instead
mirror `flutter_riverpod`'s `Consumer`:

- `Consumer` takes a `ConsumerBuilder = Widget Function(Context, WidgetRef)`.
- The builder receives a `WidgetRef` (new, `lib/src/view/widget_ref.dart`) and
  reads whichever providers it needs through `ref.read` / `ref.watch`.

Rationale: this keeps the container out of widget code (per the agreed
"ref over container" rule) and leaves room for multi-provider consumers
without an API break. The single-provider case is still trivially expressible
inside the builder.

## How `ref.watch` is mimicked without Flutter

`flutter_riverpod` implements `WidgetRef.watch` on `ConsumerStatefulElement`:
it calls `container.listen(provider, (_, _) => markNeedsBuild())` and returns
the current value. `markNeedsBuild` is a Flutter `Element` API and is therefore
Flutter-exclusive.

`t22e` does not have `StatefulWidget`/`State`/`markNeedsBuild` yet, so for
this milestone `ConsumerElement` implements `WidgetRef` with `watch` simply
delegating to `context.read` (i.e. a one-shot read with **no subscription**).
The full `container.listen` + element-dirty technique is deferred to
Milestone 6 — see `tasks/milestone-6/NOTE-consumer-rebuild-wiring.md`.

## ConsumerElement: a transparent proxy, not a render object

`ConsumerElement extends Element implements WidgetRef`. It owns no
`RenderObject`; it compiles the builder's widget into a single child and
delegates `layout` and `paint` to that child. This is the smallest correct
implementation for compile-time provider reads and matches the proxy-element
intent of the task's "How" section. When Milestone 6 adds subscription-driven
rebuilds, `ConsumerElement` can either gain a `markNeedsBuild`-equivalent or
be rebased on a future `StatefulWidget`/`State` abstraction.

## Scope deferred to Milestone 6

Consistent with the child tasks of Story 5, the following are **not** part of
this implementation and are documented for Milestone 6:

- Provider subscription registration inside `watch`.
- Rebuild / `markNeedsBuild`-equivalent on provider change.
- Frame triggering without a scheduler (driven by app-context, widget-context,
  or MVVM notifiers).
- Selective rebuild optimization and multi-provider `Consumer` extras.

## Files touched

- `lib/src/view/context.dart` — now wraps `ProviderContainer` and exposes
  `read`.
- `lib/src/view/widget_ref.dart` — new `WidgetRef` interface (`read`, `watch`).
- `lib/src/view/components/consumer.dart` — new `Consumer`,
  `ConsumerBuilder`, `ConsumerElement`.
- `lib/src/view/pipeline_widget_binding.dart` — `renderWidget` now constructs a
  `Context(ProviderContainer())` by default and accepts a real context.
- `lib/t22e.dart` — exports `WidgetRef`, `Consumer`, `ConsumerBuilder`,
  `ConsumerElement`.
- Existing widget/element tests updated to pass `Context(ProviderContainer())`
  instead of `const Context()`.
- `test/view/components/consumer_test.dart` — new unit tests.