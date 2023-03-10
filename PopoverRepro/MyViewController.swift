import Cocoa

class MyViewController: NSViewController {
  override func loadView() {
    self.view = MyView()
  }

  override func mouseDown(with event: NSEvent) {
    // We receive this call in all situations except when BOTH of the following
    // conditions are true:
    // * this view controller is the content view controller of an NSPopover.
    // * the Reduce Transparency accessibility setting is enabled.
    print("MyViewController got mouseDown!")
  }
}

/// An NSView subclass to demonstrate that mouseDown is being received by the
/// view.
///
/// This bug repros regardless of whether or not NSView itself or a subclass is
/// used, but the subclass does help with debugging since:
/// * We can see that the view IS receiving a mouseDown call
/// * We can probe self.nextResponder immediately before we call super.mouseDown
///   to see that the next responder is, indeed the same MyViewController
///   instance dumped when printing the responder chain when opening the
///   popover.
class MyView: NSView {
  override func mouseDown(with event: NSEvent) {
    // Uncomment to verify that MyView receives a mouseDown: call regardless
    // of whether it's in an NSWindow or NSPopover, and regardless of whether or
    // not the Reduce Transparency setting is enabled.

    // print("MyView got mouseDown!")

    // Checking self.nextResponder here shows that it is indeed a
    // MyViewController with the same address as the one printed when the
    // popover was opened.
    super.mouseDown(with: event)
  }
  
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    // The bug repros just fine regardless of what we return here, or indeed
    // whether the method is overridden at all, but it's likely that anyone
    // dealing with mouseclicks in a popover would want this set to true.
    return true
  }
}
