#!/usr/bin/env swift

import Foundation

do {
  let day3Problem1 = try Day3Problem1(arguments: CommandLine.arguments)

  day3Problem1.processInput { result in
    switch result {
    case .success(let systemReport):
      print(
        "- Summary ---------------",
        "Gamma: \(systemReport.gamma ?? 0)",
        "Epsilon: \(systemReport.epsilon ?? 0)",
        "Result: \(systemReport.powerConsumption ?? 0)",
        "-------------------------",
        separator: "\n"
      )
    case .failure(let error):
      print("Unexpected error: \(error)")
    }
  }
} catch Day3Problem1.Errors.invalidUsage {
  print("Usage: \(CommandLine.arguments[0]) <filename>")

} catch Day3Problem1.Errors.fileNotFound(let filename) {
  print("File not found: \(filename)")

} catch {
  print("Unexpected error: \(error)")
}

// MARK: - Runner

struct SystemReport {
  var gamma: Int? {
    var result: String = ""

    for index in 0..<scoreboard.keys.count {
      guard
        let positionScoreboard = scoreboard[index],
        let (mode, _) = positionScoreboard.max(by: { $0.1 < $1.1 })
      else {
        continue
      }

      result.append(mode)
    }

    return Int(result, radix: 2)
  }

  var epsilon: Int? {
    var result: String = ""

    for index in 0..<scoreboard.keys.count {
      guard
        let positionScoreboard = scoreboard[index],
        let (mode, _) = positionScoreboard.max(by: { $0.1 > $1.1 })
      else {
        continue
      }

      result.append(mode)
    }

    return Int(result, radix: 2)
  }

  var powerConsumption: Int? {
    guard let gamma = gamma, let epsilon = epsilon else { return nil }

    return gamma * epsilon
  }

  private var scoreboard: [Int: [String: Int]] = [:]

  mutating func add(_ string: String) {
    for (position, character) in string.enumerated() {
      scoreboard[position, default: [:]][String(character), default: 0] += 1
    }
  }
}

final class Day3Problem1 {
  enum Errors: Error {
    case invalidUsage
    case fileNotFound(filename: String)
    case invalidInstruction(instruction: String)
    case unableToOpenFile(filename: String)
    case unableToCreateSystemReport
  }

  // MARK: Properties

  let fileManager = FileManager.default
  let fileURL: URL

  // MARK: Initialization

  init(arguments: [String]) throws {
    guard arguments.count == 2 else {
      throw Errors.invalidUsage
    }

    let filename = arguments[1]

    self.fileURL = URL(fileURLWithPath: fileManager.currentDirectoryPath).appendingPathComponent(filename)

    guard fileManager.fileExists(atPath: fileURL.path) else {
      throw Errors.fileNotFound(filename: filename)
    }
  }

  func processInput(completion: @escaping (Result<SystemReport, Error>) -> Void) {
    var systemReport = SystemReport()

    let filename = fileURL.path

    guard let filePointer: UnsafeMutablePointer<FILE> = fopen(filename, "r") else {
      completion(.failure(Day3Problem1.Errors.unableToOpenFile(filename: filename)))
      return
    }

    var lineByteArrayPointer: UnsafeMutablePointer<CChar>? = nil
    var lineCap: Int = 0
    var bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)

    while (bytesRead > 0) {
      let rawLine = String.init(cString: lineByteArrayPointer!)
      let line = rawLine.trimmingCharacters(in: CharacterSet.newlines)

      systemReport.add(line)

      bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)
    }

    completion(.success(systemReport))
  }
}
