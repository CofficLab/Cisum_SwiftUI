import SwiftUI

/// Image 扩展功能演示视图
struct ImageExtensionDemoView: View {
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - A
            ImageIconSection(title: "A", icons: [
                ("添加", Image.add, "add"),
                ("添加圆形", Image.addCircle, "addCircle"),
                ("添加用户", Image.addUser, "addUser"),
                ("活动记录", Image.activity, "activity"),
                ("活动记录填充", Image.activityFill, "activityFill"),
                ("专辑", Image.album, "album"),
                ("飞行模式", Image.airplane, "airplane"),
                ("App Store", Image.appStore, "appStore"),
                ("Apple终端", Image.appleTerminal, "appleTerminal"),
                ("箭头循环", Image.arrowClockwise, "arrowClockwise"),
                ("向上箭头圆形", Image.arrowUpCircle, "arrowUpCircle"),
                ("艺术家", Image.artist, "artist"),
                ("音频文档", Image.audioDocument, "audioDocument"),
                ("输入设备", Image.audioInput, "audioInput"),
                ("输出设备", Image.audioOutput, "audioOutput"),
            ])

            // MARK: - B
            ImageIconSection(title: "B", icons: [
                ("电池", Image.battery, "battery"),
                ("快退", Image.backward, "backward"),
                ("快退填充", Image.backwardEndFill, "backwardEndFill"),
                ("备份", Image.backup, "backup"),
                ("备份填充", Image.backupFill, "backupFill"),
                ("备份历史", Image.backupHistory, "backupHistory"),
                ("备份恢复", Image.backupRestore, "backupRestore"),
                ("备份恢复填充", Image.backupRestoreFill, "backupRestoreFill"),
                ("背景色", Image.backgroundColor, "backgroundColor"),
            ])

            // MARK: - C
            ImageIconSection(title: "C", icons: [
                ("日历", Image.calendar, "calendar"),
                ("日历应用", Image.calendarApp, "calendarApp"),
                ("图表", Image.chart, "chart"),
                ("勾选", Image.checkmark, "checkmark"),
                ("勾选简单", Image.checkmarkSimple, "checkmarkSimple"),
                ("关闭", Image.close, "close"),
                ("云存储", Image.cloud, "cloud"),
                ("云存储填充", Image.cloudFill, "cloudFill"),
                ("云下载", Image.cloudDownload, "cloudDownload"),
                ("云禁用", Image.cloudSlash, "cloudSlash"),
                ("云上传", Image.cloudUpload, "cloudUpload"),
                ("代码", Image.code, "code"),
                ("评论", Image.comment, "comment"),
                ("评论填充", Image.commentFill, "commentFill"),
                ("控制台", Image.console, "console"),
                ("通讯录", Image.contacts, "contacts"),
                ("通讯录填充", Image.contactsFill, "contactsFill"),
                ("复制", Image.copy, "copy"),
                ("剪切", Image.cut, "cut"),
            ])

            // MARK: - D
            ImageIconSection(title: "D", icons: [
                ("调试", Image.debug, "debug"),
                ("文档", Image.doc, "doc"),
                ("二进制文档", Image.docBinary, "docBinary"),
                ("文档", Image.document, "document"),
                ("文档填充", Image.documentFill, "documentFill"),
                ("文档填充备选", Image.documentFillAlt, "documentFillAlt"),
                ("下载", Image.download, "download"),
                ("圆点圆形", Image.dotCircle, "dotCircle"),
            ])

            // MARK: - E
            ImageIconSection(title: "E", icons: [
                ("编辑", Image.edit, "edit"),
                ("编辑圆形", Image.editCircle, "editCircle"),
                ("编辑填充", Image.editCircleFill, "editCircleFill"),
                ("均衡器", Image.equalizer, "equalizer"),
                ("错误", Image.error, "error"),
                ("退出全屏", Image.exitFullscreen, "exitFullscreen"),
            ])

            // MARK: - F
            ImageIconSection(title: "F", icons: [
                ("FaceTime", Image.faceTime, "faceTime"),
                ("FaceTime填充", Image.faceTimeFill, "faceTimeFill"),
                ("筛选", Image.filter, "filter"),
                ("访达", Image.finder, "finder"),
                ("访达填充", Image.finderFill, "finderFill"),
                ("第一页", Image.firstPage, "firstPage"),
                ("快进", Image.forward, "forward"),
                ("快进填充", Image.forwardEndFill, "forwardEndFill"),
                ("文件夹", Image.folder, "folder"),
                ("文件夹填充", Image.folderFill, "folderFill"),
                ("全屏", Image.fullscreen, "fullscreen"),
            ])

            // MARK: - G
            ImageIconSection(title: "G", icons: [
                ("快退10秒", Image.gobackward10, "gobackward10"),
                ("快进10秒", Image.goforward10, "goforward10"),
                ("齿轮", Image.gear, "gear"),
                ("地球", Image.globe, "globe"),
                ("网格", Image.grid, "grid"),
                ("网格填充", Image.gridFill, "gridFill"),
            ])

            // MARK: - H
            ImageIconSection(title: "H", icons: [
                ("家庭", Image.home, "home"),
                ("家庭填充", Image.homeFill, "homeFill"),
                ("喜欢", Image.heart, "heart"),
                ("喜欢填充", Image.heartFill, "heartFill"),
                ("健康", Image.health, "health"),
                ("健康填充", Image.healthFill, "healthFill"),
            ])

            // MARK: - I
            ImageIconSection(title: "I", icons: [
                ("iCloud文件夹", Image.iCloudFolder, "iCloudFolder"),
                ("iCloud下载", Image.iCloudDownload, "iCloudDownload"),
                ("图片文档", Image.imageDocument, "imageDocument"),
                ("信息", Image.info, "info"),
            ])

            // MARK: - L
            ImageIconSection(title: "L", icons: [
                ("歌词", Image.lyrics, "lyrics"),
                ("最后一页", Image.lastPage, "lastPage"),
                ("定位", Image.location, "location"),
                ("定位填充", Image.locationFill, "locationFill"),
                ("列表", Image.list, "list"),
                ("列表圆形", Image.listCircle, "listCircle"),
                ("列表填充", Image.listCircleFill, "listCircleFill"),
                ("日志", Image.log, "log"),
                ("链接", Image.link, "link"),
                ("链接圆形", Image.linkCircle, "linkCircle"),
            ])

            // MARK: - M
            ImageIconSection(title: "M", icons: [
                ("地图", Image.maps, "maps"),
                ("地图填充", Image.mapsFill, "mapsFill"),
                ("消息", Image.message, "message"),
                ("消息填充", Image.messageFill, "messageFill"),
                ("信息", Image.messages, "messages"),
                ("信息填充", Image.messagesFill, "messagesFill"),
                ("邮件", Image.mail, "mail"),
                ("邮件填充", Image.mailFill, "mailFill"),
                ("邮件应用", Image.mailApp, "mailApp"),
                ("邮件应用填充", Image.mailAppFill, "mailAppFill"),
                ("减少", Image.minus, "minus"),
                ("减少圆形", Image.minusCircle, "minusCircle"),
                ("更多", Image.more, "more"),
                ("音乐", Image.music, "music"),
                ("音乐填充", Image.musicFill, "musicFill"),
                ("音符", Image.musicNote, "musicNote"),
                ("音符列表", Image.musicNoteList, "musicNoteList"),
                ("音乐仓库", Image.musicLibrary, "musicLibrary"),
                ("音乐仓库填充", Image.musicLibraryFill, "musicLibraryFill"),
                ("音乐文件夹", Image.musicFolder, "musicFolder"),
                ("静音", Image.mute, "mute"),
            ])

            // MARK: - N
            ImageIconSection(title: "N", icons: [
                ("下一页", Image.nextPage, "nextPage"),
                ("下一页圆形", Image.nextPageCircle, "nextPageCircle"),
                ("下一页圆形填充", Image.nextPageCircleFill, "nextPageCircleFill"),
                ("备忘录", Image.notes, "notes"),
                ("备忘录填充", Image.notesFill, "notesFill"),
                ("通知", Image.notification, "notification"),
                ("通知填充", Image.notificationFill, "notificationFill"),
                ("通知设置", Image.notificationSetting, "notificationSetting"),
            ])

            // MARK: - O
            ImageIconSection(title: "O", icons: [
            ])

            // MARK: - P
            ImageIconSection(title: "P", icons: [
                ("粘贴", Image.paste, "paste"),
                ("暂停", Image.pause, "pause"),
                ("暂停填充", Image.pauseFill, "pauseFill"),
                ("PDF文档", Image.pdfDocument, "pdfDocument"),
                ("人物圆形", Image.personCircle, "personCircle"),
                ("人事圆形", Image.personCropCircle, "personCropCircle"),
                ("用户组", Image.personGroup, "personGroup"),
                ("用户组填充", Image.personGroupFill, "personGroupFill"),
                ("用户组禁用", Image.personGroupSlash, "personGroupSlash"),
                ("播放", Image.play, "play"),
                ("播放填充", Image.playFill, "playFill"),
                ("占位", Image.placeholder, "placeholder"),
                ("占位备选", Image.placeholderAlt, "placeholderAlt"),
                ("上一页", Image.previousPage, "previousPage"),
                ("上一页圆形", Image.previousPageCircle, "previousPageCircle"),
                ("上一页圆形填充", Image.previousPageCircleFill, "previousPageCircleFill"),
                ("预览", Image.preview, "preview"),
                ("预览填充", Image.previewFill, "previewFill"),
                ("照片", Image.photos, "photos"),
                ("照片填充", Image.photosFill, "photosFill"),
                ("画笔", Image.paintbrush, "paintbrush"),
                ("调色板", Image.paintpalette, "paintpalette"),
                ("密码", Image.passwords, "passwords"),
                ("密码填充", Image.passwordsFill, "passwordsFill"),
            ])

            // MARK: - Q
            ImageIconSection(title: "Q", icons: [
                ("质量", Image.qualitySetting, "qualitySetting"),
            ])

            // MARK: - R
            ImageIconSection(title: "R", icons: [
                ("重置", Image.reset, "reset"),
                ("标尺", Image.ruler, "ruler"),
                ("刷新", Image.refresh, "refresh"),
                ("刷新圆形", Image.refreshCircle, "refreshCircle"),
                ("刷新圆形填充", Image.refreshCircleFill, "refreshCircleFill"),
                ("双箭头刷新", Image.refreshAlt, "refreshAlt"),
                ("双箭头刷新圆形", Image.refreshAltCircle, "refreshAltCircle"),
                ("双箭头刷新圆形填充", Image.refreshAltCircleFill, "refreshAltCircleFill"),
                ("重新开始", Image.restart, "restart"),
                ("重新加载", Image.reload, "reload"),
                ("删除用户", Image.removeUser, "removeUser"),
                ("只读", Image.readOnly, "readOnly"),
                ("只读填充", Image.readOnlyFill, "readOnlyFill"),
                ("单曲循环", Image.repeat1, "repeat1"),
                ("列表循环", Image.repeatAll, "repeatAll"),
                ("提醒事项", Image.reminders, "reminders"),
                ("提醒事项填充", Image.remindersFill, "remindersFill"),
            ])

            // MARK: - S
            ImageIconSection(title: "S", icons: [
                ("Safari", Image.safari, "safari"),
                ("Safari填充", Image.safariFill, "safariFill"),
                ("随机播放", Image.shuffle, "shuffle"),
                ("快捷指令", Image.shortcuts, "shortcuts"),
                ("快捷指令填充", Image.shortcutsFill, "shortcutsFill"),
                ("删除线", Image.strikethrough, "strikethrough"),
                ("搜索", Image.search, "search"),
                ("设置", Image.settings, "settings"),
                ("设置填充", Image.settingsFill, "settingsFill"),
                ("分享", Image.share, "share"),
                ("分享备选", Image.shareAlt, "shareAlt"),
                ("排序", Image.sort, "sort"),
                ("在Finder中显示", Image.showInFinder, "showInFinder"),
                ("在Finder中显示填充", Image.showInFinderFill, "showInFinderFill"),
                ("同步", Image.sync, "sync"),
                ("同步圆形", Image.syncCircle, "syncCircle"),
                ("同步圆形填充", Image.syncCircleFill, "syncCircleFill"),
                ("系统设置", Image.systemSettings, "systemSettings"),
                ("系统设置填充", Image.systemSettingsFill, "systemSettingsFill"),
                ("停止", Image.stop, "stop"),
                ("星标", Image.star, "star"),
                ("星标填充", Image.starFill, "starFill"),
                ("股市", Image.stocks, "stocks"),
                ("速度计", Image.speedometer, "speedometer"),
                ("中速", Image.speedometerMedium, "speedometerMedium"),
                ("高速", Image.speedometerHigh, "speedometerHigh"),
                ("正方形", Image.square, "square"),
                ("虚线正方形", Image.squareDashed, "squareDashed"),
                ("圆形叠加正方形", Image.squareOnCircle, "squareOnCircle"),
            ])

            // MARK: - T
            ImageIconSection(title: "T", icons: [
                ("表格", Image.table, "table"),
                ("表格填充", Image.tableFill, "tableFill"),
                ("表格合并", Image.tableMerge, "tableMerge"),
                ("工具栏", Image.toolbar, "toolbar"),
                ("工具栏填充", Image.toolbarFill, "toolbarFill"),
                ("顶部工具栏", Image.topToolbar, "topToolbar"),
                ("顶部工具栏填充", Image.topToolbarFill, "topToolbarFill"),
                ("清除", Image.trash, "trash"),
                ("清除填充", Image.trashFill, "trashFill"),
                ("文本文档", Image.textDocument, "textDocument"),
                ("TextEdit", Image.textEdit, "textEdit"),
                ("TextEdit填充", Image.textEditFill, "textEditFill"),
                ("主题", Image.themeSetting, "themeSetting"),
                ("计时器", Image.timer, "timer"),
                ("计时器填充", Image.timerFill, "timerFill"),
                ("终端", Image.terminal, "terminal"),
                ("终端填充", Image.terminalFill, "terminalFill"),
                ("终端应用", Image.terminalApp, "terminalApp"),
            ])

            // MARK: - U
            ImageIconSection(title: "U", icons: [
                ("下划线", Image.underline, "underline"),
                ("上传", Image.upload, "upload"),
                ("上传备选", Image.uploadAlt, "uploadAlt"),
                ("用户", Image.user, "user"),
                ("用户填充", Image.userFill, "userFill"),
            ])

            // MARK: - V
            ImageIconSection(title: "V", icons: [
                ("版本", Image.versionInfo, "versionInfo"),
                ("视频文档", Image.videoDocument, "videoDocument"),
                ("语音备忘录", Image.voiceMemos, "voiceMemos"),
                ("音量", Image.volume, "volume"),
                ("音量填充", Image.volumeFill, "volumeFill"),
                ("音量调节", Image.volumeSlider, "volumeSlider"),
                ("音量设置", Image.volumeSetting, "volumeSetting"),
            ])

            // MARK: - W
            ImageIconSection(title: "W", icons: [
                ("WiFi", Image.wifi, "wifi"),
                ("钱包", Image.wallet, "wallet"),
                ("钱包填充", Image.walletFill, "walletFill"),
                ("警告", Image.warning, "warning"),
                ("天气", Image.weather, "weather"),
                ("天气填充", Image.weatherFill, "weatherFill"),
            ])

            // MARK: - X
            ImageIconSection(title: "X", icons: [
                ("Xcode", Image.xcode, "xcode"),
                ("Xcode填充", Image.xcodeFill, "xcodeFill"),
            ])

            // MARK: - Y
            ImageIconSection(title: "Y", icons: [
            ])

            // MARK: - Z
            ImageIconSection(title: "Z", icons: [
                ("压缩文档", Image.zipDocument, "zipDocument"),
            ])
        }
        .padding()
        .frame(width: 600)
    }
}

/// Image 图标分类展示组件
struct ImageIconSection: View {
    let title: String
    let icons: [(String, Image, String)]

    var body: some View {
        if !icons.isEmpty {
            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 110)),
                ], spacing: 16) {
                    ForEach(0..<icons.count, id: \.self) { index in
                        ImageDemoItem(name: icons[index].0, image: icons[index].1, identifier: icons[index].2)
                    }
                }
                .padding()
                .background(.background.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

/// Image 图标演示项
struct ImageDemoItem: View {
    let name: String
    let image: Image
    let identifier: String

    var body: some View {
        VStack(spacing: 4) {
            image
                .font(.title2)
                .frame(height: 30)
            Text(name)
                .font(.caption)
                .foregroundStyle(.primary)
            Text(identifier)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospaced()
        }
    }
}

#if DEBUG
#Preview("Image图标演示") {
    NavigationStack {
        ImageExtensionDemoView()
    }
}
#endif
