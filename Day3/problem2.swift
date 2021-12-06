#!/usr/bin/env swift

import Foundation

do {
  let runner = try Runner(arguments: CommandLine.arguments)

  runner.processInput { result in
    switch result {
    case .success(let systemReport):
      print(
        "- Summary ---------------",
        "CO2 Scrubber Rating: \(systemReport.co2ScrubberRating ?? 0)",
        "Oxygen Generator Rating: \(systemReport.oxygenGeneratorRating ?? 0)",
        "Life Support Rating: \(systemReport.lifeSupportRating ?? 0)",
        "-------------------------",
        separator: "\n"
      )
    case .failure(let error):
      print("Unexpected error: \(error)")
    }
  }
} catch Runner.Errors.invalidUsage {
  print("Usage: \(CommandLine.arguments[0]) <filename>")

} catch Runner.Errors.fileNotFound(let filename) {
  print("File not found: \(filename)")

} catch {
  print("Unexpected error: \(error)")
}

// MARK: - Runner

struct SystemReport {
  var gamma: Int? {
    let scoreboard = self.scoreboard
    var result: String = ""

    for index in 0..<scoreboard.count {
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
    let scoreboard = self.scoreboard
    var result: String = ""

    for index in 0..<scoreboard.count {
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

  var lifeSupportRating: Int? {
    guard let co2ScrubberRating = co2ScrubberRating, let oxygenGeneratorRating = oxygenGeneratorRating else { return nil }
    return co2ScrubberRating * oxygenGeneratorRating
  }

  var co2ScrubberRating: Int? {
    let count = entries.map({ $0.count }).max() ?? 0

    let resultList: [String] = (0..<count).reduce(entries) { partialResult, index in
      guard partialResult.count > 1 else { return partialResult }
      let buckets: [String: [String]] = partialResult.reduce(into: [:]) { partialBuckets, string in
        let stringIndex = string.index(string.startIndex, offsetBy: index)
        partialBuckets[String(string[stringIndex]), default: []].append(string)
      }

      let zeroBucket = buckets["0"] ?? []
      let oneBucket = buckets["1"] ?? []

      if zeroBucket.count == oneBucket.count {
        return zeroBucket
      } else {
        return [zeroBucket, oneBucket].max(by: { $0.count > $1.count }) ?? []
      }
    }

    guard let result = resultList.first else { return nil }

    return Int(result, radix: 2)
  }

  var oxygenGeneratorRating: Int? {
    let count = entries.map({ $0.count }).max() ?? 0

    let resultList: [String] = (0..<count).reduce(entries) { partialResult, index in
      let buckets: [String: [String]] = partialResult.reduce(into: [:]) { partialBuckets, string in
        let stringIndex = string.index(string.startIndex, offsetBy: index)
        partialBuckets[String(string[stringIndex]), default: []].append(string)
      }

      return buckets.max(by: { $0.value.count <= $1.value.count })?.value ?? []
    }

    guard let result = resultList.first else { return nil }

    return Int(result, radix: 2)
  }

  private var scoreboard: [Int: [String: Int]] {
    entries.reduce(into: [:]) { result, string in
      for (position, character) in string.enumerated() {
        result[position, default: [:]][String(character), default: 0] += 1
      }
    }
  }

  private var entries: [String] = []

  mutating func add(_ string: String) {
    entries.append(string)
  }
}

final class Runner {
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
      completion(.failure(Runner.Errors.unableToOpenFile(filename: filename)))
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
