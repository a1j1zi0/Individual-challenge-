import Foundation

/// حفظ وقراءة تقدّم المستخدم.
/// نستخدم UserDefaults لأن البيانات سجل واحد صغير (هدف + أيام)، فما تحتاج قاعدة بيانات مثل SwiftData.
/// `defaults` قابل للتغيير عشان الاختبارات تستخدم مخزن مؤقت منفصل
struct ProgressStore {
    var defaults: UserDefaults = .standard
    var key: String = "learningProgress"

    func load() -> LearningProgress? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(LearningProgress.self, from: data)
    }

    func save(_ progress: LearningProgress?) {
        guard let progress, let data = try? JSONEncoder().encode(progress) else {
            defaults.removeObject(forKey: key)
            return
        }
        defaults.set(data, forKey: key)
    }
}
