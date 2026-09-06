#if os(macOS)
import AppKit
import SwiftUI

/// Synchronizes the SwiftUI layout minimum with the native macOS window.
///
/// A SwiftUI `frame(minWidth:)` constrains its view hierarchy, but does not
/// necessarily update `NSWindow.contentMinSize`. Without the native value,
/// the window can still be resized below the actual player layout.
struct MainWindowMinimumSizeBridge: NSViewRepresentable {
    let minimumSize: CGSize

    static func apply(to window: NSWindow, minimumSize: CGSize) {
        guard minimumSize.width.isFinite, minimumSize.height.isFinite else { return }

        window.contentMinSize = minimumSize
        window.minSize = window.frameRect(
            forContentRect: NSRect(origin: .zero, size: minimumSize)
        ).size

        let currentContentSize = window.contentRect(forFrameRect: window.frame).size
        guard currentContentSize.width < minimumSize.width
            || currentContentSize.height < minimumSize.height else { return }

        window.setContentSize(
            CGSize(
                width: max(currentContentSize.width, minimumSize.width),
                height: max(currentContentSize.height, minimumSize.height)
            )
        )
    }

    func makeNSView(context: Context) -> WindowMinimumSizeView {
        WindowMinimumSizeView(minimumSize: minimumSize)
    }

    func updateNSView(_ nsView: WindowMinimumSizeView, context: Context) {
        nsView.minimumSize = minimumSize
        nsView.applyMinimumSize()
    }
}

final class WindowMinimumSizeView: NSView {
    var minimumSize: CGSize
    private var observedWindow: NSWindow?
    private var resizeObserver: NSObjectProtocol?
    private var isApplyingMinimumSize = false

    init(minimumSize: CGSize) {
        self.minimumSize = minimumSize
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateWindowObservation()
        applyMinimumSize()
    }

    deinit {
        if let resizeObserver {
            NotificationCenter.default.removeObserver(resizeObserver)
        }
    }

    private func updateWindowObservation() {
        guard window !== observedWindow else { return }

        if let resizeObserver {
            NotificationCenter.default.removeObserver(resizeObserver)
            self.resizeObserver = nil
        }

        observedWindow = window
        guard let window else { return }

        resizeObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            self?.applyMinimumSize()
        }
    }

    func applyMinimumSize() {
        guard !isApplyingMinimumSize,
              let window,
              minimumSize.width.isFinite,
              minimumSize.height.isFinite else { return }

        isApplyingMinimumSize = true
        defer { isApplyingMinimumSize = false }

        MainWindowMinimumSizeBridge.apply(to: window, minimumSize: minimumSize)
    }
}
#endif
