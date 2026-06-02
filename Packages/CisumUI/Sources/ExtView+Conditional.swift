import SwiftUI

// MARK: - Conditional View Modifier

extension View {
    /// 条件性地显示视图
    ///
    /// 当条件为 true 时显示原视图，当条件为 false 时返回 EmptyView（不占用布局空间）
    ///
    /// ```swift
    /// Text("Hello")
    ///     .if(isLoggedIn)
    ///
    /// Button("Delete") { }
    ///     .if(hasPermission)
    /// ```
    ///
    /// - Parameter condition: 是否显示视图的条件
    /// - Returns: 当条件为 true 时返回原视图，否则返回 EmptyView
    @ViewBuilder
    public func `if`(_ condition: Bool) -> some View {
        if condition {
            self
        } else {
            EmptyView()
        }
    }

    /// 条件性地显示视图（带替代视图）
    ///
    /// 当条件为 true 时显示原视图，当条件为 false 时显示替代视图
    ///
    /// ```swift
    /// Button("Delete") { }
    ///     .if(hasPermission, otherwise: {
    ///         Text("No Permission")
    ///             .foregroundColor(.red)
    ///     })
    ///
    /// Image(systemName: "star.fill")
    ///     .if(isFavorite, otherwise: {
    ///         Image(systemName: "star")
    ///     })
    /// ```
    ///
    /// - Parameters:
    ///   - condition: 是否显示视图的条件
    ///   - otherwise: 当条件为 false 时显示的替代视图构建器
    /// - Returns: 根据条件返回原视图或替代视图
    @ViewBuilder
    public func `if`<Else: View>(_ condition: Bool, otherwise: () -> Else) -> some View {
        if condition {
            self
        } else {
            otherwise()
        }
    }

    /// 条件性地修饰视图
    ///
    /// 当条件为 true 时应用修饰符，否则返回原视图
    ///
    /// ```swift
    /// Text("Hello")
    ///     .if(isHighlighted) { view in
    ///         view.background(Color.yellow)
    ///     }
    ///
    /// Button("Click") { }
    ///     .if(isDisabled) { view in
    ///         view.disabled(true)
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - condition: 是否应用修饰符的条件
    ///   - modifier: 当条件为 true 时应用的修饰符
    /// - Returns: 根据条件返回修饰后的视图或原视图
    @ViewBuilder
    public func `if`(_ condition: Bool, transform modifier: (Self) -> some View) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }

    /// 条件性地修饰视图（带 else 分支）
    ///
    /// 根据条件应用不同的修饰符
    ///
    /// ```swift
    /// Text("Status")
    ///     .if(isSuccess, if: { view in
    ///         view.foregroundColor(.green)
    ///     }, otherwise: { view in
    ///         view.foregroundColor(.red)
    ///     })
    /// ```
    ///
    /// - Parameters:
    ///   - condition: 判断条件
    ///   - trueTransform: 条件为 true 时应用的修饰符
    ///   - falseTransform: 条件为 false 时应用的修饰符
    /// - Returns: 应用相应修饰符后的视图
    @ViewBuilder
    public func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if trueTransform: (Self) -> TrueContent,
        otherwise falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

// MARK: - Platform Conditional View Modifier

extension View {
    /// 仅在 macOS 上显示视图
    ///
    /// ```swift
    /// Text("macOS Feature")
    ///     .ifMacOS()
    /// ```
    @ViewBuilder
    public func ifMacOS() -> some View {
        #if os(macOS)
        self
        #else
        EmptyView()
        #endif
    }

    /// 仅在 iOS 上显示视图
    ///
    /// ```swift
    /// Text("iOS Feature")
    ///     .ifiOS()
    /// ```
    @ViewBuilder
    public func ifiOS() -> some View {
        #if os(iOS)
        self
        #else
        EmptyView()
        #endif
    }

    /// 仅在 tvOS 上显示视图
    ///
    /// ```swift
    /// Text("tvOS Feature")
    ///     .iftvOS()
    /// ```
    @ViewBuilder
    public func iftvOS() -> some View {
        #if os(tvOS)
        self
        #else
        EmptyView()
        #endif
    }

    /// 仅在 watchOS 上显示视图
    ///
    /// ```swift
    /// Text("watchOS Feature")
    ///     .ifwatchOS()
    /// ```
    @ViewBuilder
    public func ifwatchOS() -> some View {
        #if os(watchOS)
        self
        #else
        EmptyView()
        #endif
    }

    /// 仅在 visionOS 上显示视图
    ///
    /// ```swift
    /// Text("visionOS Feature")
    ///     .ifvisionOS()
    /// ```
    @ViewBuilder
    public func ifvisionOS() -> some View {
        #if os(visionOS)
        self
        #else
        EmptyView()
        #endif
    }

    /// 仅在 macOS 或 iOS 上显示视图
    ///
    /// ```swift
    /// Text("Apple Platform Feature")
    ///     .ifAppleMobileOrDesktop()
    /// ```
    @ViewBuilder
    public func ifAppleMobileOrDesktop() -> some View {
        #if os(macOS) || os(iOS)
        self
        #else
        EmptyView()
        #endif
    }
}
