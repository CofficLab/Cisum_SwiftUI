import LumiUI

/// Cisum 自实现：LumiUI 的 `AppUI`（DesignTokens 的 typealias 包装）是 internal，
/// 跨模块不可见。此处提供同构的 public 访问入口，供 Cisum 特有组件使用。
/// 仅暴露 LumiUI 中 public 的 token（Color/Motion 在 LumiUI 内为 internal，不在其中）。
public enum AppUI {
    public typealias Typography = DesignTokens.Typography
    public typealias Spacing = DesignTokens.Spacing
    public typealias Radius = DesignTokens.Radius
    public typealias Material = DesignTokens.Material
    public typealias Duration = DesignTokens.Duration
    public typealias Shadow = DesignTokens.Shadow
}
