#!/bin/bash

# 为缺少 order 属性的插件文件添加 order 属性

# AudioSettingsPlugin: 音频设置
sed -i '' '/static let verbose/a\
    /// 注册顺序设为 10，在其他音频插件之后执行\
    static var order: Int { 10 }' Plugins/AudioSettings/AudioSettingsPlugin.swift

# BookSettingsPlugin: 有声书设置
sed -i '' '/static let verbose/a\
    /// 注册顺序设为 11，在其他插件之后执行\
    static var order: Int { 11 }' Plugins/BookSettings/BookSettingsPlugin.swift

# OpenButtonPlugin: 打开按钮
sed -i '' '/static let verbose/a\
    /// 注册顺序设为 20，在其他插件之后执行\
    static var order: Int { 20 }' Plugins/OpenButtonPlugin.swift

# LikeButtonPlugin: 喜欢按钮
sed -i '' '/static let verbose/a\
    /// 注册顺序设为 21，在其他插件之后执行\
    static var order: Int { 21 }' Plugins/LikeButtonPlugin.swift

# BookDBView/BookDBPlugin: 有声书仓库
sed -i '' '/static let verbose/a\
    /// 注册顺序设为 12，在其他插件之后执行\
    static var order: Int { 12 }' Plugins/BookDBView/BookDBPlugin.swift

# CopyPlugin: 复制插件
sed -i '' '/static let verbose/a\
    /// 注册顺序设为 0，优先执行\
    static var order: Int { 0 }' Plugins/CopyPlugin/CopyPlugin.swift

# AudioDBView/AudioDBPlugin: 音频仓库
sed -i '' '/static let verbose/a\
    /// 注册顺序设为 1，在 CopyPlugin 之后执行\
    static var order: Int { 1 }' Plugins/AudioDBView/AudioDBPlugin.swift

# DebugPlugin: 调试插件
sed -i '' '/static let emoji/a\
    /// 注册顺序设为 100，最后执行\
    static var order: Int { 100 }' Plugins/DebugPlugin.swift

echo "Order properties added to all plugin files"
