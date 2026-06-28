# Project Notes — t22e

## Architectural decisions

### Layering: engine must not depend on the view layer

After the Milestone 3 three-tree alignment (see
`tasks/milestone-5/NOTE-milestone-3-rework.md`), the codebase follows Flutter's
render architecture with a strict, one-directional dependency direction:

```
view (Widget / Element)  →  engine (RenderObject / Pipeline)  →  io / models
```

Concretely, no file under `lib/src/engine/` imports anything from
`lib/src/view/`. The widget layer builds and drives the render tree; the engine
never knows that widgets exist.

### Build-pass bridge for the rendering pipeline (Milestone 5, Story 3)

The task file `tasks/milestone-5/task-5-3-3.md` predates the rework and reads:

> Update `lib/src/engine/pipeline.dart`: accept a root widget builder or
> instance from the application…

Taken literally, this would make `engine/pipeline.dart` import
`lib/src/view/`, violating the layering rule above. The intent is therefore
reinterpreted as: *add a build pass that connects the declarative widget tree
to the existing `Pipeline`*, implemented in the **view layer**.

Implementation: `lib/src/view/pipeline_widget_binding.dart` defines an
`@internal` extension `PipelineWidgetBinding on Pipeline` with
`renderWidget(Widget appChild, Size terminalSize, {Context context})`. It
builds a `Root`, compiles and mounts the element tree, extracts the root
`RenderObject`, and delegates to `Pipeline.render` for the layout, paint,
diff, and flush passes. `engine/pipeline.dart` stays free of widget
knowledge.

This satisfies the task's acceptance criteria (the engine accepts a widget
tree root, builds each frame with the current terminal size, and runs the
full pipeline end-to-end) while preserving the post-rework layer boundary.
