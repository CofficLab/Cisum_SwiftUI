import Foundation

@MainActor
public protocol ToastProviding: AnyObject {
    func show(_ toast: CisumToast)
    func presentError(title: String, message: String)
    func dismissError()
    func showLoading(title: String, detail: String?)
    func dismissLoading()
    func dismissAll()
}

public extension ToastProviding {
    func show(
        _ title: String,
        detail: String? = nil,
        style: CisumToastStyle = .info,
        duration: TimeInterval? = nil
    ) {
        show(CisumToast(title: title, detail: detail, style: style, duration: duration))
    }
}
