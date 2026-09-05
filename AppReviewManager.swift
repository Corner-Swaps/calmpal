//
//  AppReviewManager.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Production-ready Apple In-App Review Manager conforming to App Store Review Guideline 5.6.1.
//

import Foundation
import StoreKit
import UIKit
import Combine

/// Manages StoreKit in-app rating and review prompt presentations in compliance
/// with Apple App Store Review Guideline 5.6.1.
public final class AppReviewManager: ObservableObject {

    // MARK: - Singleton Instance

    public static let shared = AppReviewManager()

    // MARK: - Storage Keys

    public enum Keys {
        public static let originalInstallDate = "AppReview_OriginalInstallDate"
        public static let lifetimeLaunches = "AppReview_LifetimeLaunches"
        public static let currentVersion = "AppReview_CurrentVersion"
        public static let currentVersionInstallDate = "AppReview_CurrentVersionInstallDate"
        public static let currentVersionLaunches = "AppReview_CurrentVersionLaunches"
        public static let hasSubmittedReview = "AppReview_HasSubmittedReview"
        public static let lastPromptLaunchCount = "AppReview_LastPromptLaunchCount"
        public static let lastPromptDate = "AppReview_LastPromptDate"
        public static let isExistingUser = "AppReview_IsExistingUser"
    }

    // MARK: - Dependencies & Configuration

    private let userDefaults: UserDefaults
    private let bundle: Bundle
    private var cancellables = Set<AnyCancellable>()
    private var pendingReviewTask: Task<Void, Never>?

    /// Delay in seconds before presenting the review dialog after criteria are satisfied,
    /// allowing the user to settle into their calming session without interruption.
    public let presentationDelaySeconds: TimeInterval

    // MARK: - Initializer

    public init(
        userDefaults: UserDefaults = .standard,
        bundle: Bundle = .main,
        presentationDelaySeconds: TimeInterval = 11.0,
        observeLifecycleNotifications: Bool = true
    ) {
        self.userDefaults = userDefaults
        self.bundle = bundle
        self.presentationDelaySeconds = presentationDelaySeconds

        if observeLifecycleNotifications {
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
                .sink { [weak self] _ in
                    self?.handleAppForeground()
                }
                .store(in: &cancellables)
        }
    }

    deinit {
        pendingReviewTask?.cancel()
    }

    // MARK: - Public State Accessors

    /// Original installation date, preserved or detected from Document directory creation date.
    public var originalInstallDate: Date {
        get {
            if let date = userDefaults.object(forKey: Keys.originalInstallDate) as? Date {
                return date
            }
            let detected = detectInstallDate()
            userDefaults.set(detected, forKey: Keys.originalInstallDate)
            return detected
        }
        set {
            userDefaults.set(newValue, forKey: Keys.originalInstallDate)
        }
    }

    /// Total lifetime launches across all installed versions.
    public var lifetimeLaunches: Int {
        get { userDefaults.integer(forKey: Keys.lifetimeLaunches) }
        set { userDefaults.set(newValue, forKey: Keys.lifetimeLaunches) }
    }

    /// App version string currently being tracked.
    public var currentVersion: String {
        get { userDefaults.string(forKey: Keys.currentVersion) ?? "" }
        set { userDefaults.set(newValue, forKey: Keys.currentVersion) }
    }

    /// Date the current version was installed or first launched.
    public var currentVersionInstallDate: Date {
        get {
            if let date = userDefaults.object(forKey: Keys.currentVersionInstallDate) as? Date {
                return date
            }
            return originalInstallDate
        }
        set {
            userDefaults.set(newValue, forKey: Keys.currentVersionInstallDate)
        }
    }

    /// Number of launches under the current version.
    public var currentVersionLaunches: Int {
        get { userDefaults.integer(forKey: Keys.currentVersionLaunches) }
        set { userDefaults.set(newValue, forKey: Keys.currentVersionLaunches) }
    }

    /// Whether the user has actually submitted a review.
    /// When true, review prompts are permanently locked out.
    public var hasSubmittedReview: Bool {
        get { userDefaults.bool(forKey: Keys.hasSubmittedReview) }
        set { userDefaults.set(newValue, forKey: Keys.hasSubmittedReview) }
    }

    /// Lifetime launch count recorded at the time of the most recent prompt.
    public var lastPromptLaunchCount: Int? {
        get {
            if userDefaults.object(forKey: Keys.lastPromptLaunchCount) != nil {
                return userDefaults.integer(forKey: Keys.lastPromptLaunchCount)
            }
            return nil
        }
        set {
            if let val = newValue {
                userDefaults.set(val, forKey: Keys.lastPromptLaunchCount)
            } else {
                userDefaults.removeObject(forKey: Keys.lastPromptLaunchCount)
            }
        }
    }

    /// Timestamp of the most recent review prompt presentation.
    public var lastPromptDate: Date? {
        get { userDefaults.object(forKey: Keys.lastPromptDate) as? Date }
        set { userDefaults.set(newValue, forKey: Keys.lastPromptDate) }
    }

    /// Flag indicating whether the user is an existing user updating from a prior build.
    public var isExistingUser: Bool {
        get { userDefaults.bool(forKey: Keys.isExistingUser) }
        set { userDefaults.set(newValue, forKey: Keys.isExistingUser) }
    }

    // MARK: - Lifecycle Handlers

    /// Invoked at application launch (`.onAppear` in root SwiftUI view or App delegate).
    /// Tracks launches, checks version changes, and schedules review dialog if eligible.
    public func handleAppLaunch() {
        trackLaunch()
        checkAndSchedulePromptIfEligible()
    }

    /// Invoked when the application returns to foreground (`UIApplication.willEnterForegroundNotification`).
    public func handleAppForeground() {
        checkAndSchedulePromptIfEligible()
    }

    // MARK: - Launch & Version Tracking

    private func trackLaunch() {
        // Ensure install date is initialized and preserved
        _ = originalInstallDate

        // Increment lifetime launches
        lifetimeLaunches += 1

        // Version-specific tracking
        let appVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let storedVersion = currentVersion

        if storedVersion.isEmpty {
            // First time tracking with this manager
            currentVersion = appVersion
            currentVersionInstallDate = originalInstallDate
            currentVersionLaunches = 1
        } else if storedVersion != appVersion {
            // App update detected
            isExistingUser = true
            currentVersion = appVersion
            currentVersionInstallDate = Date()
            currentVersionLaunches = 1
        } else {
            // Continued on current version
            currentVersionLaunches += 1
        }
    }

    /// Detects original install date using the Document directory creation date
    /// for existing users updating to builds with AppReviewManager.
    private func detectInstallDate() -> Date {
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return Date()
        }

        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: docURL.path)
            if let creationDate = attrs[.creationDate] as? Date {
                // If directory creation date is noticeably older than now (> 2 minutes),
                // this indicates an existing installation updating.
                if Date().timeIntervalSince(creationDate) > 120 {
                    isExistingUser = true
                }
                return creationDate
            }
        } catch {
            // Fallback to now
        }

        return Date()
    }

    // MARK: - Milestone & Eligibility Rules

    /// Evaluates whether the user satisfies the criteria for presenting an in-app review.
    ///
    /// Rules:
    /// - If `hasSubmittedReview == true`, permanently locked (returns false).
    /// - If previously prompted (user dismissed without submitting):
    ///   Re-prompt only after 15 more app opens OR 15 days have elapsed.
    /// - If never prompted before:
    ///   - Existing users: lifetime launches >= 15 OR launches since update >= 15
    ///                     OR days since original install >= 15 OR days since update >= 15.
    ///   - New users: lifetime launches >= 15 OR days since install >= 15.
    public func isEligibleForReview(at now: Date = Date()) -> Bool {
        // Rule 4: Submission lock permanently disables all prompts
        guard !hasSubmittedReview else {
            return false
        }

        // Rule 4: Re-prompting cadence after a dismissal
        if let lastPromptDate = self.lastPromptDate, let lastPromptLaunch = self.lastPromptLaunchCount {
            let launchesSincePrompt = lifetimeLaunches - lastPromptLaunch
            let daysSincePrompt = now.timeIntervalSince(lastPromptDate) / 86400.0
            return launchesSincePrompt >= 15 || daysSincePrompt >= 15.0
        }

        // Rule 2: Milestone Triggers for first-time prompt
        let daysSinceOriginalInstall = now.timeIntervalSince(originalInstallDate) / 86400.0

        if isExistingUser {
            let daysSinceUpdate = now.timeIntervalSince(currentVersionInstallDate) / 86400.0
            return lifetimeLaunches >= 15 ||
                   currentVersionLaunches >= 15 ||
                   daysSinceOriginalInstall >= 15.0 ||
                   daysSinceUpdate >= 15.0
        } else {
            return lifetimeLaunches >= 15 || daysSinceOriginalInstall >= 15.0
        }
    }

    // MARK: - Prompt Scheduling & Presentation

    /// Checks review eligibility and, if satisfied, schedules presentation after exactly 11 seconds.
    public func checkAndSchedulePromptIfEligible() {
        guard isEligibleForReview() else {
            return
        }

        // Cancel any pending task to prevent overlapping timer presentation
        pendingReviewTask?.cancel()

        let delayNanos = UInt64(presentationDelaySeconds * 1_000_000_000)

        pendingReviewTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(nanoseconds: delayNanos)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }
            guard let self = self else { return }

            // Re-verify that the application is still active in foreground
            guard UIApplication.shared.applicationState == .active else {
                return
            }

            // Re-verify eligibility (in case user submitted review or state mutated)
            guard self.isEligibleForReview() else {
                return
            }

            self.presentReviewDialog()
        }
    }

    /// Presents the StoreKit review dialog targeting the foreground-active `UIWindowScene`.
    @MainActor
    public func presentReviewDialog() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return
        }

        // Record prompt occurrence for re-prompt cadence
        lastPromptLaunchCount = lifetimeLaunches
        lastPromptDate = Date()

        // StoreKit Presentation complying with iOS versions
        if #available(iOS 16.0, *) {
            AppStore.requestReview(in: windowScene)
        } else {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    // MARK: - Submission Lock API

    /// Permanently locks out review prompts when a user submits a review.
    /// Call this when an in-app review confirmation or manual review submission action completes.
    public func markReviewSubmitted() {
        hasSubmittedReview = true
        pendingReviewTask?.cancel()
        pendingReviewTask = nil
    }

    // MARK: - Testing & Diagnostics Utilities

    /// Resets all review tracking data stored in UserDefaults (for automated testing & QA).
    public func resetAllTrackingData() {
        pendingReviewTask?.cancel()
        pendingReviewTask = nil

        userDefaults.removeObject(forKey: Keys.originalInstallDate)
        userDefaults.removeObject(forKey: Keys.lifetimeLaunches)
        userDefaults.removeObject(forKey: Keys.currentVersion)
        userDefaults.removeObject(forKey: Keys.currentVersionInstallDate)
        userDefaults.removeObject(forKey: Keys.currentVersionLaunches)
        userDefaults.removeObject(forKey: Keys.hasSubmittedReview)
        userDefaults.removeObject(forKey: Keys.lastPromptLaunchCount)
        userDefaults.removeObject(forKey: Keys.lastPromptDate)
        userDefaults.removeObject(forKey: Keys.isExistingUser)
    }
}
