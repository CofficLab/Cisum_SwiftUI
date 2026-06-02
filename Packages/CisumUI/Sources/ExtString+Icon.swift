import Foundation
import SwiftUI

public extension String {
    /// 创建一个带有图标预览的按钮
    /// ```swift
    /// let button = "star".previewIconButton()
    /// ```
    /// - Returns: 一个 Button，点击后会显示所有图标的预览
    func previewIconButton() -> some View {
        Button(action: {}) {
            Image(systemName: self)
        }
        .popover(isPresented: .constant(false)) {
            ImageExtensionDemoView()
                .frame(width: 500)
        }
    }

    // MARK: - Icons (A-Z)

    // MARK: A

    /// 访问控制图标名称 (lock.shield)
    static let iconAccessControl = "lock.shield"

    /// 账户设置图标名称 (person.circle)
    static let iconAccountSetting = "person.circle"

    /// 成就图标名称 (star.circle)
    static let iconAchievement = "star.circle"

    /// 活动记录图标名称 (flame)
    static let iconActivity = "flame"

    /// 活动记录填充图标名称 (flame.fill)
    static let iconActivityFill = "flame.fill"

    /// 活动追踪器图标名称 (figure.walk)
    static let iconActivityTracker = "figure.walk"

    /// 添加图标名称 (plus)
    static let iconAdd = "plus"

    /// 添加圆形图标名称 (plus.circle)
    static let iconAddCircle = "plus.circle"

    /// 添加用户图标名称 (person.badge.plus)
    static let iconAddUser = "person.badge.plus"

    /// 高级筛选图标名称 (line.3.horizontal.decrease.circle.fill)
    static let iconAdvancedFilter = "line.3.horizontal.decrease.circle.fill"

    /// 飞行模式图标名称 (airplane)
    static let iconAirplane = "airplane"

    /// 专辑图标名称 (square.stack)
    static let iconAlbum = "square.stack"

    /// 居中对齐图标名称 (text.aligncenter)
    static let iconAlignCenter = "text.aligncenter"

    /// 两端对齐图标名称 (text.justify)
    static let iconAlignJustify = "text.justify"

    /// 左对齐图标名称 (text.alignleft)
    static let iconAlignLeft = "text.alignleft"

    /// 右对齐图标名称 (text.alignright)
    static let iconAlignRight = "text.alignright"

    /// Apple终端图标名称 (apple.terminal)
    static let iconAppleTerminal = "apple.terminal"

    /// 审批图标名称 (checkmark.circle.badge.questionmark)
    static let iconApproval = "checkmark.circle.badge.questionmark"

    /// App Store图标名称 (app.store)
    static let iconAppStore = "storefront"

    /// 箭头循环图标名称 (arrow.clockwise)
    static let iconArrowClockwise = "arrow.clockwise"

    /// 向上箭头圆形图标名称 (arrow.up.circle)
    static let iconArrowUpCircle = "arrow.up.circle"

    /// 艺术家图标名称 (music.mic)
    static let iconArtist = "music.mic"

    /// 音频设备切换图标名称 (airpodspro)
    static let iconAudioDevice = "airpodspro"

    /// 音频文档图标名称 (music.note)
    static let iconAudioDocument = "music.note"

    /// 输入设备图标名称 (mic)
    static let iconAudioInput = "mic"

    /// 输出设备图标名称 (speaker.wave.2.circle)
    static let iconAudioOutput = "speaker.wave.2.circle"

    /// 自动化图标名称 (gear.badge.automatic)
    static let iconAutomation = "gear.badge.automatic"

    // MARK: B

    /// 背景色图标名称 (paintbrush)
    static let iconBackgroundColor = "paintbrush"

    /// 备份图标名称 (arrow.clockwise.icloud)
    static let iconBackup = "arrow.clockwise.icloud"

    /// 备份填充图标名称 (arrow.clockwise.icloud.fill)
    static let iconBackupFill = "arrow.clockwise.icloud.fill"

    /// 备份历史图标名称 (clock.arrow.circlepath)
    static let iconBackupHistory = "clock.arrow.circlepath"

    /// 备份恢复图标名称 (arrow.counterclockwise.icloud)
    static let iconBackupRestore = "arrow.counterclockwise.icloud"

    /// 备份恢复填充图标名称 (arrow.counterclockwise.icloud.fill)
    static let iconBackupRestoreFill = "arrow.counterclockwise.icloud.fill"

    /// 快退图标名称 (backward)
    static let iconBackward = "backward"

    /// 快退填充图标名称 (backward.end.fill)
    static let iconBackwardEndFill = "backward.end.fill"

    /// 电池图标名称 (battery.100)
    static let iconBattery = "battery.100"

    /// 加粗图标名称 (bold)
    static let iconBold = "bold"

    /// AI大脑图标名称 (brain.head.profile)
    static let iconBrain = "brain.head.profile"

    /// 预算图标名称 (dollarsign.circle)
    static let iconBudget = "dollarsign.circle"

    /// 项目符号列表图标名称 (list.bullet)
    static let iconBulletList = "list.bullet"

    // MARK: C

    /// 缓存设置图标名称 (trash.circle)
    static let iconCacheSetting = "trash.circle"

    /// 计算器图标名称 (plus.slash.minus)
    static let iconCalculator = "plus.slash.minus"

    /// 日历图标名称 (calendar)
    static let iconCalendar = "calendar"

    /// 日历应用图标名称 (calendar.badge.clock)
    static let iconCalendarApp = "calendar.badge.clock"

    /// 图表图标名称 (chart.bar)
    static let iconChart = "chart.bar"

    /// 勾选图标名称 (checkmark.circle.fill)
    static let iconCheckmark = "checkmark.circle.fill"

    /// 勾选图标名称 (checkmark)
    static let iconCheckmarkSimple = "checkmark"

    /// 向下箭头图标名称 (chevron.down)
    static let iconChevronDown = "chevron.down"

    /// 清除格式图标名称 (clear)
    static let iconClearFormat = "clear"

    /// 关闭图标名称 (xmark.circle.fill)
    static let iconClose = "xmark.circle.fill"

    /// 时钟图标名称 (clock)
    static let iconClock = "clock"

    /// 时钟填充图标名称 (clock.fill)
    static let iconClockFill = "clock.fill"

    /// 时钟应用图标名称 (clock.badge)
    static let iconClockApp = "clock.badge"

    /// 时钟应用填充图标名称 (clock.badge.fill)
    static let iconClockAppFill = "clock.badge.fill"

    /// 云存储图标名称 (cloud)
    static let iconCloud = "cloud"

    /// 云下载图标名称 (cloud.download)
    static let iconCloudDownload = "cloud.download"

    /// 云存储填充图标名称 (cloud.fill)
    static let iconCloudFill = "cloud.fill"

    /// 云禁用图标名称 (icloud.slash)
    static let iconCloudSlash = "icloud.slash"

    /// 云上传图标名称 (icloud.and.arrow.up)
    static let iconCloudUpload = "icloud.and.arrow.up"

    /// 代码图标名称 (chevron.left.forwardslash.chevron.right)
    static let iconCode = "chevron.left.forwardslash.chevron.right"

    /// 评论图标名称 (bubble.right)
    static let iconComment = "bubble.right"

    /// 评论填充图标名称 (bubble.right.fill)
    static let iconCommentFill = "bubble.right.fill"

    /// 控制台图标名称 (keyboard)
    static let iconConsole = "keyboard"

    /// 连接设置图标名称 (network)
    static let iconConnectionSetting = "network"

    /// 通讯录图标名称 (person.crop.rectangle)
    static let iconContacts = "person.crop.rectangle"

    /// 通讯录填充图标名称 (person.crop.rectangle.fill)
    static let iconContactsFill = "person.crop.rectangle.fill"

    /// 复制图标名称 (doc.on.doc)
    static let iconCopy = "doc.on.doc"

    /// 证书图标名称 (rosette)
    static let iconCertificate = "rosette"

    /// 图表分析图标名称 (chart.bar.xaxis)
    static let iconChartAnalysis = "chart.bar.xaxis"

    /// 创意图标名称 (lightbulb)
    static let iconCreativity = "lightbulb"

    /// 剪切图标名称 (scissors)
    static let iconCut = "scissors"

    // MARK: D

    /// 圆点圆形图标名称 (dot.circle)
    static let iconDotCircle = "dot.circle"

    /// 二进制文档图标名称 (doc.text.fill.viewfinder)
    static let iconDocBinary = "doc.text.fill.viewfinder"

    /// 复制图标名称 (doc.on.doc)
    static let iconDoc = "doc.on.doc"

    /// 文档图标名称 (doc)
    static let iconDocument = "doc.text"

    /// 文档填充内容图标 (text.badge.plus)
    static let iconDocumentFill = "text.badge.plus"

    /// 文档填充内容填充样式图标 (doc.text.fill)
    static let iconDocumentFillAlt = "doc.text.fill"

    /// 调试图标名称 (ladybug)
    static let iconDebug = "ladybug"

    /// 下载图标名称 (arrow.down.circle)
    static let iconDownload = "arrow.down.circle"

    /// 数据导出图标名称 (arrow.up.doc)
    static let iconDataExport = "arrow.up.doc"

    /// 数据导入图标名称 (arrow.down.doc)
    static let iconDataImport = "arrow.down.doc"

    /// 数据排序图标名称 (arrow.up.arrow.down)
    static let iconDataSort = "arrow.up.arrow.down"

    /// 数据可视化图标名称 (chart.pie)
    static let iconDataVisualization = "chart.pie"

    /// 方向图标名称 (arrow.triangle.turn.up.right.diamond)
    static let iconDirections = "arrow.triangle.turn.up.right.diamond"

    /// 开发者设置图标名称 (hammer.circle)
    static let iconDeveloperSetting = "hammer.circle"

    // MARK: E

    /// 编辑图标名称 (pencil)
    static let iconEdit = "pencil"

    /// 编辑圆形图标名称 (pencil.circle)
    static let iconEditCircle = "pencil.circle"

    /// 编辑填充图标名称 (pencil.circle.fill)
    static let iconEditCircleFill = "pencil.circle.fill"

    /// 均衡器图标名称 (waveform.path.ecg)
    static let iconEqualizer = "waveform.path.ecg"

    /// 错误图标名称 (exclamationmark.circle.fill)
    static let iconError = "exclamationmark.circle.fill"

    /// 退出全屏图标名称 (arrow.down.right.and.arrow.up.left)
    static let iconExitFullscreen = "arrow.down.right.and.arrow.up.left"

    // MARK: F

    /// 财务报表图标名称 (chart.bar.doc.horizontal)
    static let iconFinancialReport = "chart.bar.doc.horizontal"

    /// FaceTime图标名称 (video.bubble)
    static let iconFaceTime = "video.bubble"

    /// FaceTime填充图标名称 (video.bubble.fill)
    static let iconFaceTimeFill = "video.bubble.fill"

    /// 通讯录填充图标名称 (person.crop.rectangle.fill)
    static let iconFaceTimeFillAlt = "person.crop.rectangle.fill"

    /// 电影图标名称 (film)
    static let iconFilm = "film"

    /// 筛选图标名称 (line.3.horizontal.decrease.circle)
    static let iconFilter = "line.3.horizontal.decrease.circle"

    /// 访达图标名称 (macwindow)
    static let iconFinder = "macwindow"

    /// 访达填充图标名称 (macwindow.fill)
    static let iconFinderFill = "macwindow.fill"

    /// 第一页图标名称 (chevron.left.2)
    static let iconFirstPage = "chevron.left.2"

    /// 快进图标名称 (forward)
    static let iconForward = "forward"

    /// 快进填充图标名称 (forward.end.fill)
    static let iconForwardEndFill = "forward.end.fill"

    /// 全屏图标名称 (arrow.up.left.and.arrow.down.right)
    static let iconFullscreen = "arrow.up.left.and.arrow.down.right"

    /// 文件夹图标名称 (folder)
    static let iconFolder = "folder"

    /// 文件夹填充图标名称 (folder.fill)
    static let iconFolderFill = "folder.fill"

    /// 字体图标名称 (textformat)
    static let iconFont = "textformat"

    /// 字体大小图标名称 (textformat.size)
    static let iconFontSize = "textformat.size"

    /// 字体颜色图标名称 (textformat.alt)
    static let iconFontColor = "textformat.alt"

    /// 指纹图标名称 (touchid)
    static let iconFingerprint = "touchid"

    /// 指纹填充图标名称 (touchid.fill)
    static let iconFingerprintFill = "touchid.fill"

    // MARK: G

    /// 地理围栏图标名称 (mappin.and.ellipse)
    static let iconGeofence = "mappin.and.ellipse"

    /// 群组工作图标名称 (person.3)
    static let iconGroupWork = "person.3"

    /// 快进10秒图标名称 (goforward.10)
    static let iconGoforward10 = "goforward.10"

    /// 快退10秒图标名称 (gobackward.10)
    static let iconGobackward10 = "gobackward.10"

    /// 齿轮图标名称 (gearshape)
    static let iconGear = "gearshape"

    /// 前往图标名称 (arrow.right.circle)
    static let iconGoto = "arrow.right.circle"

    /// 地球图标名称 (globe)
    static let iconGlobe = "globe"

    /// 网格图标名称 (square.grid.2x2)
    static let iconGrid = "square.grid.2x2"

    /// 网格填充图标名称 (square.grid.2x2.fill)
    static let iconGridFill = "square.grid.2x2.fill"

    // MARK: H

    /// 健康指标图标名称 (heart.text.square)
    static let iconHealthMetrics = "heart.text.square"

    /// 健康图标名称 (heart.text.square)
    static let iconHealth = "heart.text.square"

    /// 健康填充图标名称 (heart.text.square.fill)
    static let iconHealthFill = "heart.text.square.fill"

    /// 喜欢图标名称 (heart)
    static let iconHeart = "heart"

    /// 喜欢填充图标名称 (heart.fill)
    static let iconHeartFill = "heart.fill"

    /// 家庭图标名称 (house)
    static let iconHome = "house"

    /// 家庭填充图标名称 (house.fill)
    static let iconHomeFill = "house.fill"

    /// 超链接图标名称 (link.badge.plus)
    static let iconHyperlink = "link.badge.plus"

    // MARK: I

    /// 发票图标名称 (doc.text.magnifyingglass)
    static let iconInvoice = "doc.text.magnifyingglass"

    /// iCloud下载图标名称 (arrow.down.circle.dotted)
    static let iconICloudDownload = "arrow.down.circle.dotted"

    /// 下载云图标名称 (icloud.and.arrow.down)
    static let iconICloudDownloadAlt = "icloud.and.arrow.down"

    /// iCloud 文件夹图标名称 (folder.badge.questionmark)
    static let iconICloudFolder = "folder.badge.questionmark"

    /// 图片文档图标名称 (photo)
    static let iconImageDocument = "photo"

    /// 缩进减少图标名称 (decrease.indent)
    static let iconIndentDecrease = "decrease.indent"

    /// 缩进增加图标名称 (increase.indent)
    static let iconIndentIncrease = "increase.indent"

    /// 信息图标名称 (info.circle)
    static let iconInfo = "info.circle"

    /// 图片插入图标名称 (photo.on.rectangle.angled)
    static let iconInsertImage = "photo.on.rectangle.angled"

    /// 灵感图标名称 (sparkles)
    static let iconInspiration = "sparkles"

    /// 物联网图标名称 (wifi.circle)
    static let iconIoT = "wifi.circle"

    /// 斜体图标名称 (italic)
    static let iconItalic = "italic"

    // MARK: L

    /// 布局图标名称 (rectangle.grid.2x2)
    static let iconLayout = "rectangle.grid.2x2"

    /// 学习进度图标名称 (chart.bar.fill)
    static let iconLearningProgress = "chart.bar.fill"

    /// 实时聊天图标名称 (bubble.left.and.bubble.right)
    static let iconLiveChat = "bubble.left.and.bubble.right"

    /// 位置标记图标名称 (mappin)
    static let iconLocationMarker = "mappin"

    /// 最后一页图标名称 (chevron.right.2)
    static let iconLastPage = "chevron.right.2"

    /// 链接图标名称 (link)
    static let iconLink = "link"

    /// 链接图标名称 (link.circle)
    static let iconLinkCircle = "link.circle"

    /// 列表图标名称 (list.bullet)
    static let iconList = "list.bullet"

    /// 列表圆形图标名称 (list.bullet.circle)
    static let iconListCircle = "list.bullet.circle"

    /// 列表填充图标名称 (list.bullet.circle.fill)
    static let iconListCircleFill = "list.bullet.circle.fill"

    /// 定位图标名称 (location)
    static let iconLocation = "location"

    /// 定位填充图标名称 (location.fill)
    static let iconLocationFill = "location.fill"

    /// 日志图标名称 (text.alignleft)
    static let iconLog = "text.alignleft"

    /// 歌词图标名称 (text.quote)
    static let iconLyrics = "text.quote"

    // MARK: M

    /// 地图图层图标名称 (map)
    static let iconMapLayers = "map"

    /// 医疗记录图标名称 (heart.text.square.fill)
    static let iconMedicalRecord = "heart.text.square.fill"

    /// 音乐图标名称 (music.note.house)
    static let iconMusic = "music.note.house"

    /// 音乐填充图标名称 (music.note.house.fill)
    static let iconMusicFill = "music.note.house.fill"

    /// 音符图标名称 (music.note)
    static let iconMusicNote = "music.note"

    /// 音符圆形图标名称 (music.note.circle)
    static let iconMusicNoteCircle = "music.note.circle"

    /// 音符列表图标名称 (music.note.list)
    static let iconMusicNoteList = "music.note.list"

    /// 消息图标名称 (message)
    static let iconMessage = "message"

    /// 消息填充图标名称 (message.fill)
    static let iconMessageFill = "message.fill"

    /// 邮件图标名称 (envelope)
    static let iconMailAlt = "envelope"

    /// 邮件填充图标名称 (envelope.fill)
    static let iconMailFillAlt = "envelope.fill"

    /// 减少图标名称 (minus)
    static let iconMinus = "minus"

    /// 减少圆形图标名称 (minus.circle)
    static let iconMinusCircle = "minus.circle"

    /// 更多图标名称 (ellipsis)
    static let iconMore = "ellipsis"

    /// 邮件图标名称 (envelope)
    static let iconMail = "envelope"

    /// 邮件填充图标名称 (envelope.fill)
    static let iconMailFill = "envelope.fill"

    /// 音乐仓库图标名称 (music.note.house)
    static let iconMusicLibrary = "music.note.house"

    /// 音乐仓库填充图标名称 (music.note.house.fill)
    static let iconMusicLibraryFill = "music.note.house.fill"

    /// 邮件应用图标名称 (envelope.badge)
    static let iconMailApp = "envelope.badge"

    /// 邮件应用填充图标名称 (envelope.badge.fill)
    static let iconMailAppFill = "envelope.badge.fill"

    /// 音乐历史图标名称 (clock.arrow.circlepath)
    static let iconMusicHistory = "clock.arrow.circlepath"

    /// 下载音乐图标名称 (arrow.down.circle.dotted)
    static let iconMusicDownload = "arrow.down.circle.dotted"

    /// 音乐质量图标名称 (dial.high.fill)
    static let iconMusicQuality = "dial.high.fill"

    /// 音乐文件夹图标名称 (folder.fill.badge.plus)
    static let iconMusicFolder = "folder.fill.badge.plus"

    /// 地图图标名称 (map)
    static let iconMaps = "map"

    /// 地图填充图标名称 (map.fill)
    static let iconMapsFill = "map.fill"

    /// 信息图标名称 (message.badge)
    static let iconMessages = "message.badge"

    /// 信息填充图标名称 (message.badge.fill)
    static let iconMessagesFill = "message.badge.fill"

    /// 静音图标名称 (speaker.slash)
    static let iconMute = "speaker.slash"

    // MARK: N

    /// 导航图标名称 (location.north.line)
    static let iconNavigation = "location.north.line"

    /// 网络状态图标名称 (wifi)
    static let iconNetworkStatus = "wifi"

    /// 下一页图标名称 (chevron.right)
    static let iconNextPage = "chevron.right"

    /// 下一页圆形图标名称 (chevron.right.circle)
    static let iconNextPageCircle = "chevron.right.circle"

    /// 下一页圆形填充图标名称 (chevron.right.circle.fill)
    static let iconNextPageCircleFill = "chevron.right.circle.fill"

    /// 下一首歌曲图标名称 (forward.end)
    static let iconNextTrack = "forward.end"

    /// 下一首歌曲填充图标名称 (forward.end.fill)
    static let iconNextTrackFill = "forward.end.fill"

    /// 通知图标名称 (bell)
    static let iconNotification = "bell"

    /// 通知填充图标名称 (bell.fill)
    static let iconNotificationFill = "bell.fill"

    /// 通知设置图标名称 (bell.badge)
    static let iconNotificationSetting = "bell.badge"

    /// 正在播放指示器图标名称 (waveform)
    static let iconNowPlaying = "waveform"

    /// 数字1填充圆形图标名称 (1.circle.fill)
    static let iconNumberCircleFill1 = "1.circle.fill"

    /// 数字2填充圆形图标名称 (2.circle.fill)
    static let iconNumberCircleFill2 = "2.circle.fill"

    /// 数字3填充圆形图标名称 (3.circle.fill)
    static let iconNumberCircleFill3 = "3.circle.fill"

    /// 编号列表图标名称 (list.number)
    static let iconNumberList = "list.number"

    /// 备忘录图标名称 (note.text)
    static let iconNotes = "note.text"

    /// 备忘录填充图标名称 (note.text.fill)
    static let iconNotesFill = "note.text.fill"

    // MARK: P

    /// 支付图标名称 (creditcard)
    static let iconPayment = "creditcard"

    /// 权限图标名称 (key)
    static let iconPermissions = "key"

    /// 电话图标名称 (phone)
    static let iconPhoneCall = "phone"

    /// 演示图标名称 (rectangle.inset.filled.and.person.filled)
    static let iconPresentation = "rectangle.inset.filled.and.person.filled"

    /// 隐私图标名称 (hand.raised")
    static let iconPrivacy = "hand.raised"

    /// 调色板图标名称 (paintpalette)
    static let iconPaintpalette = "paintpalette"

    /// 画笔图标名称 (paintbrush)
    static let iconPaintbrush = "paintbrush"

    /// 粘贴图标名称 (doc.on.clipboard)
    static let iconPaste = "doc.on.clipboard"

    /// 暂停图标名称 (pause.circle)
    static let iconPause = "pause.circle"

    /// 暂停填充图标名称 (pause.fill)
    static let iconPauseFill = "pause.fill"

    /// 人事圆形图标名称 (person.crop.circle)
    static let iconPersonCropCircle = "person.crop.circle"

    /// 人物圆形图标名称 (person.circle)
    static let iconPersonCircle = "person.circle"

    /// 用户组图标名称 (person.2.circle)
    static let iconPersonGroup = "person.2.circle"

    /// 用户组填充图标名称 (person.2.circle.fill)
    static let iconPersonGroupFill = "person.2.circle.fill"

    /// 用户组禁用图标名称 (person.2.slash)
    static let iconPersonGroupSlash = "person.2.slash"

    /// 暂停图标名称 (pause.circle)
    static let iconPauseAlt = "pause.circle"

    /// PDF文档图标名称 (doc.text.fill)
    static let iconPDFDocument = "doc.text.fill"

    /// 占位图标名称 (photo.badge.plus)
    static let iconPlaceholder = "photo.badge.plus"

    /// 播放图标名称 (play.circle)
    static let iconPlay = "play.circle"

    /// 播放填充图标名称 (play.fill)
    static let iconPlayFill = "play.fill"

    /// 加号图标名称 (plus)
    static let iconPlus = "plus"

    /// 上一页图标名称 (chevron.left)
    static let iconPreviousPage = "chevron.left"

    /// 上一页圆形图标名称 (chevron.left.circle)
    static let iconPreviousPageCircle = "chevron.left.circle"

    /// 上一页圆形填充图标名称 (chevron.left.circle.fill)
    static let iconPreviousPageCircleFill = "chevron.left.circle.fill"

    /// 上一首歌曲图标名称 (backward.end)
    static let iconPreviousTrack = "backward.end"

    /// 上一首歌曲填充图标名称 (backward.end.fill)
    static let iconPreviousTrackFill = "backward.end.fill"

    /// 预览图标名称 (doc.richtext)
    static let iconPreview = "doc.richtext"

    /// 预览填充图标名称 (doc.richtext.fill)
    static let iconPreviewFill = "doc.richtext.fill"

    /// 添加到播放列表图标名称 (plus.circle)
    static let iconPlaylistAdd = "plus.circle"

    /// 从播放列表移除图标名称 (minus.circle)
    static let iconPlaylistRemove = "minus.circle"

    /// 照片图标名称 (photo.on.rectangle)
    static let iconPhotos = "photo.on.rectangle"

    /// 照片填充图标名称 (photo.on.rectangle.fill)
    static let iconPhotosFill = "photo.on.rectangle.fill"

    /// 密码图标名称 (key)
    static let iconPasswords = "key"

    /// 密码填充图标名称 (key.fill)
    static let iconPasswordsFill = "key.fill"

    // MARK: Q

    /// 质量设置图标名称 (dial.high.fill)
    static let iconQualitySetting = "dial.high.fill"

    /// QuickTime图标名称 (play.rectangle)
    static let iconQuickTime = "play.rectangle"

    /// QuickTime填充图标名称 (play.rectangle.fill)
    static let iconQuickTimeFill = "play.rectangle.fill"

    // MARK: R

    /// 排名图标名称 (list.number)
    static let iconRanking = "list.number"

    /// 提醒图标名称 (bell.badge)
    static let iconReminder = "bell.badge"

    /// 重置图标名称 (arrow.counterclockwise)
    static let iconReset = "arrow.counterclockwise"

    /// 刷新图标名称 (arrow.clockwise)
    static let iconRefresh = "arrow.clockwise"

    /// 刷新圆形图标名称 (arrow.clockwise.circle)
    static let iconRefreshCircle = "arrow.clockwise.circle"

    /// 刷新圆形填充图标名称 (arrow.clockwise.circle.fill)
    static let iconRefreshCircleFill = "arrow.clockwise.circle.fill"

    /// 双箭头刷新图标名称 (arrow.2.circlepath)
    static let iconRefreshAlt = "arrow.2.circlepath"

    /// 双箭头刷新圆形图标名称 (arrow.2.circlepath.circle)
    static let iconRefreshAltCircle = "arrow.2.circlepath.circle"

    /// 双箭头刷新圆形填充图标名称 (arrow.2.circlepath.circle.fill)
    static let iconRefreshAltCircleFill = "arrow.2.circlepath.circle.fill"

    /// 重新加载图标名称 (gobackward)
    static let iconReload = "gobackward"

    /// 重新开始图标名称 (restart.circle)
    static let iconRestart = "restart.circle"

    /// 删除用户图标名称 (person.badge.minus)
    static let iconRemoveUser = "person.badge.minus"

    /// 只读模式图标名称 (lock)
    static let iconReadOnly = "lock"

    /// 只读模式填充图标名称 (lock.fill)
    static let iconReadOnlyFill = "lock.fill"

    /// 标尺图标名称 (ruler)
    static let iconRuler = "ruler"

    /// 提醒事项图标名称 (list.bullet.rectangle)
    static let iconReminders = "list.bullet.rectangle"

    /// 提醒事项填充图标名称 (list.bullet.rectangle.fill)
    static let iconRemindersFill = "list.bullet.rectangle.fill"

    /// 单曲循环图标名称 (repeat.1)
    static let iconRepeat1 = "repeat.1"

    /// 列表循环图标名称 (repeat)
    static let iconRepeatAll = "repeat"

    // MARK: S

    /// 卫星视图图标名称 (map.circle)
    static let iconSatelliteView = "map.circle"

    /// 日程图标名称 (calendar.badge.plus)
    static let iconSchedule = "calendar.badge.plus"

    /// 传感器网络图标名称 (sensor.tag.radiowaves.forward)
    static let iconSensorNetwork = "sensor.tag.radiowaves.forward"

    /// 智能家居图标名称 (house")
    static let iconSmartHome = "house"

    /// 智能日程图标名称 (calendar.badge.clock)
    static let iconSmartSchedule = "calendar.badge.clock"

    /// 顺序播放图标名称 (play.textured.fill)
    static let iconSequence = "play.textured.fill"

    /// 速度计图标名称 (gauge.medium)
    static let iconSpeedometer = "gauge.medium"

    /// Safari浏览器图标名称 (safari)
    static let iconSafari = "safari"

    /// Safari浏览器填充图标名称 (safari.fill)
    static let iconSafariFill = "safari.fill"

    /// 搜索图标名称 (magnifyingglass)
    static let iconSearch = "magnifyingglass"

    /// 设置图标名称 (gearshape)
    static let iconSettings = "gearshape"

    /// 设置填充图标名称 (gearshape.fill)
    static let iconSettingsFill = "gearshape.fill"

    /// 分享图标名称 (square.and.arrow.up)
    static let iconShare = "square.and.arrow.up"

    /// 分享图标名称 (square.and.arrow.up)
    static let iconShareAlt = "square.and.arrow.up"

    /// 圆形叠加正方形图标名称 (square.on.circle)
    static let iconSquareOnCircle = "square.on.circle"

    /// 虚线正方形图标名称 (square.dashed)
    static let iconSquareDashed = "square.dashed"

    /// 正方形图标名称 (square)
    static let iconSquare = "square"

    /// 随机播放图标名称 (shuffle)
    static let iconShuffle = "shuffle"

    /// 排序图标名称 (arrow.up.arrow.down)
    static let iconSort = "arrow.up.arrow.down"

    /// 在Finder中显示图标名称 (arrow.forward.circle)
    static let iconShowInFinder = "arrow.forward.circle"

    /// 在Finder中显示填充图标名称 (arrow.forward.circle.fill)
    static let iconShowInFinderFill = "arrow.forward.circle.fill"

    /// 星标图标名称 (star)
    static let iconStar = "star"

    /// 星标填充图标名称 (star.fill)
    static let iconStarFill = "star.fill"

    /// 停止图标名称 (stop.circle)
    static let iconStop = "stop.circle"

    /// 状态设置图标名称 (circle.fill)
    static let iconStatusSetting = "circle.fill"

    /// 股市图标名称 (chart.line.uptrend.xyaxis)
    static let iconStocks = "chart.xyaxis.line"

    /// 删除线图标名称 (strikethrough)
    static let iconStrikethrough = "strikethrough"

    /// 同步图标名称 (arrow.triangle.2.circlepath)
    static let iconSync = "arrow.triangle.2.circlepath"

    /// 同步圆形图标名称 (arrow.triangle.2.circlepath.circle)
    static let iconSyncCircle = "arrow.triangle.2.circlepath.circle"

    /// 同步圆形填充图标名称 (arrow.triangle.2.circlepath.circle.fill)
    static let iconSyncCircleFill = "arrow.triangle.2.circlepath.circle.fill"

    /// 系统设置图标名称 (gearshape.2)
    static let iconSystemSettings = "gearshape.2"

    /// 系统设置填充图标名称 (gearshape.2.fill)
    static let iconSystemSettingsFill = "gearshape.2.fill"

    /// 快捷指令图标名称 (command.square)
    static let iconShortcuts = "command.square"

    /// 快捷指令填充图标名称 (command.square.fill)
    static let iconShortcutsFill = "command.square.fill"

    /// 中速速度计图标名称 (gauge.high)
    static let iconSpeedometerMedium = "gauge.medium"

    /// 高速速度计图标名称 (gauge.badge.plus)
    static let iconSpeedometerHigh = "gauge.badge.plus"

    // MARK: T

    /// 团队协作图标名称 (person.2.wave.2)
    static let iconTeamCollaboration = "person.2.wave.2"

    /// 时间线图标名称 (timeline.selection)
    static let iconTimeline = "timeline.selection"

    /// 交易图标名称 (arrow.left.arrow.right")
    static let iconTransaction = "arrow.left.arrow.right"

    /// 表格图标名称 (tablecells)
    static let iconTable = "tablecells"

    /// 表格填充图标名称 (tablecells.fill)
    static let iconTableFill = "tablecells.fill"

    /// 表格合并图标名称 (tablecells.badge.ellipsis)
    static let iconTableMerge = "tablecells.badge.ellipsis"

    /// 终端图标名称 (terminal)
    static let iconTerminal = "terminal"

    /// 终端应用图标名称 (terminal.fill)
    static let iconTerminalApp = "terminal.fill"

    /// 终端填充图标名称 (terminal.fill)
    static let iconTerminalFill = "terminal.fill"

    /// 主题设置图标名称 (paintbrush.fill)
    static let iconThemeSetting = "paintbrush.fill"

    /// 文本文档图标名称 (doc.text)
    static let iconTextDocument = "doc.text"

    /// TextEdit图标名称 (doc.text.below.ecg)
    static let iconTextEdit = "doc.text.below.ecg"

    /// TextEdit填充图标名称 (doc.text.below.ecg.fill)
    static let iconTextEditFill = "doc.text.below.ecg.fill"

    /// 计时器图标名称 (timer)
    static let iconTimer = "timer"

    /// 计时器填充图标名称 (timer)
    /// 注意：timer.fill 在某些版本不可用，使用 timer 替代
    static let iconTimerFill = "timer"

    /// 清除图标名称 (trash)
    static let iconTrash = "trash"

    /// 清除填充图标名称 (trash.fill)
    static let iconTrashFill = "trash.fill"

    /// 顶部工具栏图标 (menubar.rectangle)
    static let iconTopToolbar = "menubar.rectangle"

    /// 顶部工具栏填充图标 (menubar.dock.rectangle)
    static let iconTopToolbarFill = "menubar.dock.rectangle"

    /// 工具栏图标 (sidebar.left)
    static let iconToolbar = "sidebar.left"

    /// 工具栏填充图标 (sidebar.left.fill)
    /// 注意：sidebar.left.fill 在某些版本不可用，使用 rectangle.leadinghalf.filled 替代
    static let iconToolbarFill = "rectangle.leadinghalf.filled"

    // MARK: U

    /// 下划线图标名称 (underline)
    static let iconUnderline = "underline"

    /// 上传图标名称 (arrow.up.circle)
    static let iconUpload = "arrow.up.circle"

    /// 用户图标名称 (person.circle)
    static let iconUser = "person.circle"

    /// 用户填充图标名称 (person.circle.fill)
    static let iconUserFill = "person.circle.fill"

    // MARK: V

    /// 视频通话图标名称 (video")
    static let iconVideoCall = "video"

    /// 生命体征图标名称 (waveform.path.ecg.rectangle")
    static let iconVitalSigns = "waveform.path.ecg.rectangle"

    /// 版本信息图标名称 (info.circle)
    static let iconVersionInfo = "info.circle"

    /// 视频文档图标名称 (video)
    static let iconVideoDocument = "video"

    /// 语音备忘录图标名称 (waveform)
    static let iconVoiceMemos = "waveform"

    /// 音量图标名称 (speaker.wave.2)
    static let iconVolume = "speaker.wave.2"

    /// 音量填充图标名称 (speaker.wave.2.fill)
    static let iconVolumeFill = "speaker.wave.2.fill"

    /// 音量设置图标名称 (speaker.wave.3)
    static let iconVolumeSetting = "speaker.wave.3"

    /// 音量调节图标名称 (slider.horizontal.3)
    static let iconVolumeSlider = "slider.horizontal.3"

    // MARK: W

    /// 白板图标名称 (rectangle.and.pencil.and.ellipsis")
    static let iconWhiteboard = "rectangle.and.pencil.and.ellipsis"

    /// 工作流图标名称 (arrow.triangle.branch")
    static let iconWorkflow = "arrow.triangle.branch"

    /// 运动图标名称 (figure.run")
    static let iconWorkout = "figure.run"

    /// 钱包图标名称 (wallet.pass)
    static let iconWallet = "wallet.pass"

    /// 钱包填充图标名称 (wallet.pass.fill)
    static let iconWalletFill = "wallet.pass.fill"

    /// 警告图标名称 (exclamationmark.triangle.fill)
    static let iconWarning = "exclamationmark.triangle.fill"

    /// 天气图标名称 (cloud.sun)
    static let iconWeather = "cloud.sun"

    /// 天气填充图标名称 (cloud.sun.fill)
    static let iconWeatherFill = "cloud.sun.fill"

    /// WiFi图标名称 (wifi)
    static let iconWiFi = "wifi"

    // MARK: X

    /// Xcode图标名称 (hammer)
    static let iconXcode = "hammer"

    /// Xcode填充图标名称 (hammer.fill)
    static let iconXcodeFill = "hammer.fill"

    // MARK: Z

    /// 压缩文档图标名称 (doc.zipper)
    static let iconZipDocument = "doc.zipper"


}

#if DEBUG
#Preview("图标演示") {
    NavigationStack {
        ImageExtensionDemoView()
    }
}
#endif
