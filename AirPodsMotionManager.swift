import Foundation
import AVFoundation
import CoreMotion

/// AirPods Pro のモーションセンサー（Pitch/Roll/Yaw）を管理する
class AirPodsMotionManager: ObservableObject {
    @Published var pitch: Double = 0
    @Published var roll:  Double = 0
    @Published var yaw:   Double = 0

    private let headphoneMotionManager = CMHeadphoneMotionManager()
    private let audioSession = AVAudioSession.sharedInstance()
    private var isUpdating = false

    /// AirPods が接続されているか
    var isAirPodsConnected: Bool {
        do {
            try audioSession.setActive(true)
            return audioSession.currentRoute.outputs.contains {
                $0.portName.lowercased().contains("airpods")
            }
        } catch {
            return false
        }
    }

    /// モーション更新を開始
    func startUpdates() {
        guard !isUpdating else { return }

        // iOS 15+ でのみ利用可能な API
        guard #available(iOS 15.0, *),
              headphoneMotionManager.isDeviceMotionAvailable else {
            print("📣 CMHeadphoneMotionManager requires iOS 15+ and device motion available")
            return
        }

        isUpdating = true

        // CMMotionManager と同じプロパティ名で更新間隔を指定
//        headphoneMotionManager.updateInterval = 1.0 / 60.0

        headphoneMotionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else {
                if let error = error {
                    print("🔴 Motion update error:", error)
                }
                return
            }

            let attitude = motion.attitude
            self.pitch = attitude.pitch
            self.roll  = attitude.roll
            self.yaw   = attitude.yaw

            print("📣 AirPods Motion — Pitch:", self.pitch,
                  "Roll:", self.roll,
                  "Yaw:", self.yaw)
        }
    }

    /// モーション更新を停止
    func stopUpdates() {
        guard isUpdating else { return }
        headphoneMotionManager.stopDeviceMotionUpdates()
        isUpdating = false
    }
}
