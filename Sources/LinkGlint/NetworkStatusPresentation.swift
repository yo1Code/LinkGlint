import Foundation

struct NetworkStatusPresentation: Equatable {
    let title: String
    let symbolName: String

    static func make(services: [NetworkService], hasLoaded: Bool) -> NetworkStatusPresentation {
        guard hasLoaded else { return .init(title: "检测中", symbolName: "network") }
        guard let active = services.first(where: { $0.isPrimary && $0.connected })
                ?? services.first(where: \.connected) else {
            return .init(title: "离线", symbolName: "network.slash")
        }
        func compact(_ value: String) -> String {
            guard value.count > 9 else { return value }
            return String(value.prefix(8)).trimmingCharacters(in: .whitespaces) + "…"
        }
        switch active.kind {
        case .wifi:
            return .init(title: "无线·\(compact(active.ssid ?? active.name))", symbolName: "wifi")
        case .ethernet:
            return .init(title: "有线·\(compact(active.name))", symbolName: "cable.connector")
        case .vpn:
            return .init(title: "VPN·\(compact(active.name))", symbolName: "lock.shield")
        case .other:
            return .init(title: "其他·\(compact(active.name))", symbolName: "network")
        }
    }
}

struct MenuBarTrafficPresentation: Equatable {
    let text: String
    let usesTwoLines: Bool

    static func make(
        networkTitle: String,
        downloadBytesPerSecond: Double,
        uploadBytesPerSecond: Double,
        showsNetworkTitle: Bool,
        showsSpeed: Bool,
        usesTwoLines: Bool,
        usesBits: Bool
    ) -> MenuBarTrafficPresentation {
        let down = "↓\(TrafficRateFormatter.string(bytesPerSecond: downloadBytesPerSecond, usesBits: usesBits))"
        let up = "↑\(TrafficRateFormatter.string(bytesPerSecond: uploadBytesPerSecond, usesBits: usesBits))"
        guard showsSpeed else {
            return .init(text: showsNetworkTitle ? networkTitle : "", usesTwoLines: false)
        }
        if usesTwoLines {
            let first = showsNetworkTitle ? networkTitle : down
            let second = showsNetworkTitle ? "\(down)  \(up)" : up
            return .init(text: "\(first)\n\(second)", usesTwoLines: true)
        }
        let text = showsNetworkTitle ? "\(networkTitle)  \(down) \(up)" : "\(down) \(up)"
        return .init(text: text, usesTwoLines: false)
    }

}

enum TrafficRateFormatter {
    static func string(bytesPerSecond: Double, usesBits: Bool) -> String {
        let safeBytes = bytesPerSecond.isFinite ? max(bytesPerSecond, 0) : 0
        let value = usesBits ? safeBytes * 8 : safeBytes
        let units = usesBits
            ? ["bps", "Kbps", "Mbps", "Gbps", "Tbps"]
            : ["B/s", "KB/s", "MB/s", "GB/s", "TB/s"]
        var scaled = value
        var unitIndex = 0
        while scaled >= 1_000, unitIndex < units.count - 1 {
            scaled /= 1_000
            unitIndex += 1
        }

        let number: String
        if unitIndex == 0 || scaled >= 10 {
            number = String(format: "%.0f", scaled)
        } else {
            number = String(format: "%.1f", scaled)
        }
        return "\(number) \(units[unitIndex])"
    }
}
