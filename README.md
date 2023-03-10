# NSPopover reduced transparency bug

This app demonstrates a bug in which mouseDown/mouseUp events are not correctly
forwarded up the responder chain for views nested inside an `NSPopover` when the
Reduced Transparency accessibility setting is enabled prior to app startup.

## Overview
The included app includes an `NSViewController` subclass, `MyViewController`,
that simply embeds an `NSView` and adds a `mouseDown:(NSEvent*)` handler that
logs a string to the console.

### Expected behaviour
In all cases, clicking within the bounds of the view managed by
`MyViewController` should trigger a `mouseDown:` call on the view controller.

### Actual behaviour
When the _Reduce Transparency_ accessibility setting is enabled *and* the view
is the content view of an `NSPopover`, `mouseDown:` is not called on clicks in
the view managed by `MyViewController`.

When the _Reduced Transparency_ accessibility setting is disabled, `mouseDown:`
is called regardless of whether the view is the content view of an `NSPopover`
or an `NSWindow`.

When the view is the content view of an `NSWindow`, `mouseDown:` is called
regardless of whether the _Reduce Transparency_ accessibility setting is
enabled.

## Reproduction steps
1. Open macOS System Settings > Accessibility > Display.
2. Enable the _Reduce Transparency_ setting.
3. From Xcode, build and launch the app.
4. Click the main window one or more times. "MyViewController got mouseDown!"
   will be logged in the debug console.
5. Click the heart status bar icon in the menu bar to open a view of the same
   type in an NSPopover.
6. Click the contents of the popover that appears. Note that nothing is logged
   to the debug console.

Repeat these steps with the _Reduce Transparency_ setting disabled to see that
mouse clicks are logged for clicks in both the main window and the popover.

## Notes

No notable differences are noted between the working and non-working scenario
when probing the responder chain. In both cases, the responder chain appears to
be:
```
<PopoverRepro.MyView: 0x11a204e10>
<PopoverRepro.MyViewController: 0x600002e36a00>
<NSPopover: 0x600003714630, animates=1, behavior=0>
<_NSPopoverWindow: 0x11a205040>
<NSStatusBarWindow: 0x14b89bb60>
```

`MyView`, an `NSView` subclass, does have its `mouseDown:` method called, and
probing self.nextResponder during that call shows that the next responder is
indeed `MyViewController`; however, the default implementation of calling
`mouseDown:` on `super` results in no call to the view controller's `mouseDown:`
method. This bug repros even if you use a plain `NSView`, but `MyView` exists to
demonstrate that the first responder's `mouseDown:` is called, but that the view
controller's is not under the above conditions.

Adding a breakpoint on all `mouseDown:` methods suggests that `NSView` itself
may not have a `mouseDown:` implementation, but its superclass `NSResponder`
does, and that implementation appears to be walking a responder chain and
triggering `forwardMethod` calls which presumably send the `mouseDown:` message
on each responder. It does seem to iterate over the correct number of items in
the responder chain, before hitting `_NSPopoverWindow`'s `mouseDown:`
implementation, which _does_ get called.

One notable difference in the view hierarchy is that when reduced transparency
is enabled, an `_NSPopoverFrameAXBackgroundView` appears in the view hierarchy
as a peer of `MyViewController`. This has no effect on the responder chain,
however.
