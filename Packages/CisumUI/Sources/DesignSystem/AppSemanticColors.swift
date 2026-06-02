import SwiftUI

public extension LumiUITheme {
    var appWindowBackground: Color { background }
    var appPanelBackground: Color { surface }
    var appPopoverBackground: Color { elevatedSurface.opacity(0.96) }
    var appToolbarBackground: Color { textSecondary.opacity(0.06) }
    var appListRowBackground: Color { textSecondary.opacity(0.05) }
    var appListRowHoverBackground: Color { textSecondary.opacity(0.08) }
    var appListRowSelectedBackground: Color { primary.opacity(0.12) }
    var appDivider: Color { divider }
    var appSubtleBorder: Color { divider.opacity(0.9) }
    var appHoverBorder: Color { textSecondary.opacity(0.14) }
    var appSelectedBorder: Color { primary.opacity(0.32) }
    var appFocusRing: Color { primary.opacity(0.55) }
    var appAccentSoftFill: Color { primary.opacity(0.10) }
    var appStatusMutedFill: Color { textSecondary.opacity(0.10) }
}
