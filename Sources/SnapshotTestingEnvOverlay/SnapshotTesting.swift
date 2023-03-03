import Foundation
import SnapshotTesting
import XCTest

/// Asserts that a given value matches a reference on disk.
///
/// - Parameters:
///   - value: A value to compare against a reference.
///   - snapshotting: A strategy for serializing, deserializing, and comparing values.
///   - name: An optional description of the snapshot.
///   - recording: Whether or not to record a new reference.
///   - timeout: The amount of time a snapshot must be generated in.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - testName: The name of the test in which failure occurred. Defaults to the function name of the test case in which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
public func assertSnapshot<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {

    let failure = verifySnapshotEnv(
        matching: try value(),
        as: snapshotting,
        named: name,
        record: recording,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
    guard let message = failure else { return }
    XCTFail(message, file: file, line: line)
}

/// Asserts that a given value matches references on disk.
///
/// - Parameters:
///   - value: A value to compare against a reference.
///   - strategies: A dictionary of names and strategies for serializing, deserializing, and comparing values.
///   - recording: Whether or not to record a new reference.
///   - timeout: The amount of time a snapshot must be generated in.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - testName: The name of the test in which failure occurred. Defaults to the function name of the test case in which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
public func assertSnapshots<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as strategies: [String: Snapshotting<Value, Format>],
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {

    try? strategies.forEach { name, strategy in
        assertSnapshot(
            matching: try value(),
            as: strategy,
            named: name,
            record: recording,
            timeout: timeout,
            file: file,
            testName: testName,
            line: line
        )
    }
}

/// Asserts that a given value matches references on disk.
///
/// - Parameters:
///   - value: A value to compare against a reference.
///   - strategies: An array of strategies for serializing, deserializing, and comparing values.
///   - recording: Whether or not to record a new reference.
///   - timeout: The amount of time a snapshot must be generated in.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - testName: The name of the test in which failure occurred. Defaults to the function name of the test case in which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
public func assertSnapshots<Value, Format>(
    matching value: @autoclosure () throws -> Value,
    as strategies: [Snapshotting<Value, Format>],
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    try? strategies.forEach { strategy in
        assertSnapshot(
            matching: try value(),
            as: strategy,
            record: recording,
            timeout: timeout,
            file: file,
            testName: testName,
            line: line
        )
    }
}
