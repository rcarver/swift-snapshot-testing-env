import Foundation
import SnapshotTesting
import XCTest

/// A set of options for how to save snapshots for each test.
public enum SnapshotDirectory {
    /// Alternate directory to save snapshots for a Swift Package.
    ///
    /// Snapshots will be saved in the specified directory, appending the name of the package, and the name of the test.
    ///
    ///  `.packageSnapshotsAtPath("/AllSnapshots")`
    ///
    ///   /MyPackage/Tests/MyTests.swift
    ///   /AllSnapshots/MyPackage/MyTests/snapshot.1.json
    ///
    /// This style may be configured via an ENV variable, for example to find snapshots
    /// in an available directory for Xcode Cloud.
    ///
    ///   SNAPSHOTTESTING_PACKAGE_PATH=/Volumes/workspace/respository/ci_scripts/snapshots
    ///
    /// For example:
    ///
    ///   /Volumes/workspace/respository/ci_scripts/snapshots/MyPackage/MyTests/snapshot1.json
    case packageSnapshotsAtPath(String)

    /// Alternate directory to save snapshots, with no special handling.
    ///
    ///  `.path("/MyProject/configured/path")`
    ///
    ///   /MyProject/MyTests.swift
    ///   /MyProject/configured/path/snapshot.1.json
    ///
    /// This style may be configured via an ENV variable, for example to find snapshots
    /// in an available directory for Xcode Cloud.
    ///
    ///   SNAPSHOTTESTING_PATH=/Volumes/workspace/respository/ci_scripts/snapshots
    ///
    /// For example:
    ///
    ///   /Volumes/workspace/respository/ci_scripts/snapshots/snapshot1.json
    case path(String)

    /// Standard directory to save snapshots.
    ///
    /// By default snapshots will be saved in a directory with the same name as the test file, and that directory will sit inside a directory `__Snapshots__` that sits next to your test file.
    ///
    ///  `.snapshotsForFile`
    ///
    ///   /MyPackage/Tests/MyTests.swift
    ///   /MyPackage/Tests/__Snapshots__/MyTests/snapshot.1.json
    case snapshotsForFile
}

extension SnapshotDirectory {
    func makeURL(fileUrl: URL, fileName: String) -> URL? {
        switch self {
        case let .packageSnapshotsAtPath(path):
            let fileComponents = fileUrl
                .deletingLastPathComponent()
                .pathComponents
            guard
                let testsIndex = fileComponents.lastIndex(of: "Tests"),
                fileComponents.endIndex > testsIndex + 1
            else { return nil }
            var base = URL(fileURLWithPath: path, isDirectory: true)
            for index in (testsIndex + 1)..<fileComponents.endIndex {
                base = base.appendingPathComponent(fileComponents[index])
            }
            return base.appendingPathComponent(fileName)
        case let .path(path):
            return URL(fileURLWithPath: path, isDirectory: true)
        case .snapshotsForFile:
            return fileUrl
                .deletingLastPathComponent()
                .appendingPathComponent("__Snapshots__")
                .appendingPathComponent(fileName)
        }
    }
    init(path: String?) {
        if let path {
            self = .path(path)
            return
        }
        if let path = ProcessInfo.processInfo.environment["SNAPSHOTTESTING_PATH"] {
            self = .path(path)
            return
        }
        if let path = ProcessInfo.processInfo.environment["SNAPSHOTTESTING_PACKAGE_PATH"] {
            self = .packageSnapshotsAtPath(path)
            return
        }
        self = .snapshotsForFile
    }
}

public func verifySnapshotEnv<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: Bool = false,
    snapshotDirectory path: String? = nil,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
)
-> String? {
    let fileUrl = URL(fileURLWithPath: "\(file)", isDirectory: false)
    let fileName = fileUrl.deletingPathExtension().lastPathComponent
    let snapshotDirectory = SnapshotDirectory(path: nil)

    guard
        let url = snapshotDirectory.makeURL(fileUrl: fileUrl, fileName: fileName)
    else {
        return "Failed to construct a URL via SnapshotDirectory"
    }

    return verifySnapshot(
        matching: try value(),
        as: snapshotting,
        named: name,
        record: recording,
        snapshotDirectory: url.path,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
}
