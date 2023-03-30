//
//  LogHelper.swift
//  SpriteKitRPG
//
//  Created by lijia xu on 11/11/22.
//

import Foundation

enum Log {
    fileprivate enum LogType {
        case debug
        case info
        case error
        case warning
    }
}

extension Log {
    static func debug(
        _ msg: String,
        fileInfo: String = #fileID,
        lineNum: Int = #line
    ) {
        add(.debug, fileInfo: fileInfo, lineNum: lineNum, msg)
    }

    static func info(
        _ msg: String,
        fileInfo: String = #fileID,
        lineNum: Int = #line
    ) {
        add(.info, fileInfo: fileInfo, lineNum: lineNum, msg)
    }

    static func error(
        _ msg: String,
        fileInfo: String = #fileID,
        lineNum: Int = #line
    ) {
        add(.error, fileInfo: fileInfo, lineNum: lineNum, msg)
    }

    static func warning(
        _ msg: String,
        fileInfo: String = #fileID,
        lineNum: Int = #line
    ) {
        add(.warning, fileInfo: fileInfo, lineNum: lineNum, msg)
    }
}

private extension Log {
    static func add(
        _ type: LogType,
        fileInfo: String,
        lineNum: Int,
        _ messages: String...
    ) {
        let lineInfo = " line: \(lineNum)"
        let msg = messages.joined(separator: " | ")

        let str = [
            type.separatorLine,
            fileInfo + lineInfo,
            pureDateString,
            localDateString,
            msg
        ].joined(separator: " ")

        print(str)
        assert(type != .error, str)
    }

    static var pureDateString: String {
        Date().description
    }

    static var localDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long

        return "local: " + formatter.string(from: Date())
    }
}

fileprivate extension Log.LogType {
    var logStringPrefix: String {
        let prefix: String
        switch self {
        case .debug:
            prefix = "DEBUG 🐛"
        case .info:
            prefix = "INFO ℹ️"
        case .error:
            prefix = "ERROR 💣"
        case .warning:
            prefix = "WARNING ⚠️"
        }

        return prefix
    }

    var separatorLine: String {
        let line = String(repeating: "-", count: 5)
        return [
            line,
            logStringPrefix,
            line
        ].joined(separator: " ")
    }
}

