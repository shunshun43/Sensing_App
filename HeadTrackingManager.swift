//// New Minimal Project - ContentView.swift
//// HeadTrackingManager.swift
import CoreMotion
import Foundation
//
// MARK: – HeadTrackingManager

/// ヘッドトラッキング用のマネージャー
class HeadTrackingManager: ObservableObject {
    @Published var pitch: Double = 0
    @Published var roll: Double  = 0
    @Published var yaw: Double   = 0

    private let motionManager = CMMotionManager()
    private var isUpdating = false

    /// トラッキングを開始
    func startTracking() {
        guard !isUpdating, motionManager.isDeviceMotionAvailable else { return }
        isUpdating = true

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            // Attitude からピッチ・ロール・ヨーを取得
            let attitude = motion.attitude
            self.pitch = attitude.pitch
            self.roll  = attitude.roll
            self.yaw   = attitude.yaw

            // データを受け取ったタイミングでコンソールに出力
            print("📣 Received HeadTracking Data — Pitch:", self.pitch,
                  " Roll:", self.roll,
                  " Yaw:", self.yaw)
        }
    }

    /// トラッキングを停止
    func stopTracking() {
        guard isUpdating else { return }
        motionManager.stopDeviceMotionUpdates()
        isUpdating = false
    }
}

//class HeadTrackingManager: ObservableObject {
//    private var motionManager: CMHeadphoneMotionManager
//    @Published var pitch: Double = 0.0
//    @Published var roll: Double = 0.0
//    @Published var yaw: Double = 0.0
//
//    init() {
//        motionManager = CMHeadphoneMotionManager()
//        print("HeadTrackingManager initialized.") // 追加
//    }
//
//    // モーションデータのトラッキングを開始する
//    func startTracking() {
//        print("startTracking() called.") // 追加
//
//        // 接続している端末でCoreMotionが使えるか否かを確認する
//        guard motionManager.isDeviceMotionAvailable else {
//            print("Headphone motion data is not available. (isDeviceMotionAvailable == false)") // メッセージ変更
//            return
//        }
//        print("isDeviceMotionAvailable is true.") // 追加
//
//        // モーションデータの更新を開始し、メインキューに送信する。
//        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
//            print("Motion data handler called.") // 追加: これが出ないのが問題
//
//            guard let self = self, let motion = motion, error == nil else {
//                print("Error in motion data handler: \(String(describing: error?.localizedDescription ?? "unknown error"))") // エラーメッセージ詳細化
//                return
//            }
//
//            // 正常にモーションデータ取得後、頭の角度を取得する
//            Task {
//                await self.updateMotionData(motion)
//            }
//        }
//    }
//
//    // モーションデータの更新を停止する
//    func stopTracking() {
//        print("stopTracking() called.") // 追加
//        motionManager.stopDeviceMotionUpdates()
//    }
//
//    // モーションデータから頭の角度（ピッチ、ロール、ヨー）を取得する
//    private func updateMotionData(_ motion: CMDeviceMotion) async {
//        await MainActor.run {
//            self.pitch = motion.attitude.pitch
//            self.roll = motion.attitude.roll
//            self.yaw = motion.attitude.yaw
//            print("Received Motion Data - Pitch: \(self.pitch), Roll: \(self.roll), Yaw: \(self.yaw)") // 再度確認
//        }
//    }
//}
