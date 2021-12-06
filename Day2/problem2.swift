#!/usr/bin/env swift

import Foundation

do {
  try Runner(arguments: CommandLine.arguments).processInput { result in
    switch result {
    case .success(let position):
      print(
        "- Summary ---------------",
        "Final Position: \(position)",
        "Result: \(position.horizontal * position.depth)",
        "-------------------------",
        separator: "\n"
      )
    case .failure(let error):
      print("Unexpected error: \(error)")
    }
  }
} catch Runner.RunnerError.invalidUsage {
  print("Usage: \(CommandLine.arguments[0]) <filename>")

} catch Runner.RunnerError.fileNotFound(let filename) {
  print("File not found: \(filename)")
} catch {
  print("Unexpected error: \(error)")
}

// MARK: - Runner

final class Runner {

  // MARK: Helper Types

  struct Position {
    var horizontal: Int
    var depth: Int
    var aim: Int

    static var zero: Position { Position(horizontal: 0, depth: 0, aim: 0) }

    fileprivate mutating func move(using instruction: Instruction) {
      switch instruction.direction {
      case .forward:
        horizontal += instruction.moves
        depth += instruction.moves * aim

      case .up:
        aim -= instruction.moves

      case .down:
        aim += instruction.moves
      }
    }
  }

  struct Instruction {
    let direction: Direction
    let moves: Int

    init(from string: String) throws {
      let components = string.components(separatedBy: " ")

      guard
        components.count == 2,
        let direction = Direction(rawValue: components[0]),
        let moves = Int(components[1])
      else {
        throw RunnerError.invalidInstruction(instruction: string)
      }

      self.direction = direction
      self.moves = moves
    }
  }

  enum Direction: String {
    case forward, up, down
  }

  enum RunnerError: Error {
    case invalidUsage
    case fileNotFound(filename: String)
    case invalidInstruction(instruction: String)
    case unableToOpenFile(filename: String)
  }

  // MARK: Properties

  let fileManager = FileManager.default
  let fileURL: URL

  // MARK: Initialization

  init(arguments: [String]) throws {
    guard arguments.count == 2 else {
      throw RunnerError.invalidUsage
    }

    let filename = arguments[1]

    self.fileURL = URL(fileURLWithPath: fileManager.currentDirectoryPath).appendingPathComponent(filename)

    guard fileManager.fileExists(atPath: fileURL.path) else {
      throw RunnerError.fileNotFound(filename: filename)
    }
  }

  // MARK: Processing

  func processInput(completion: @escaping (Result<Position, Error>) -> Void) {
    do {
      var position = Position.zero

      let filename = fileURL.path

      guard let filePointer: UnsafeMutablePointer<FILE> = fopen(filename, "r") else {
        completion(.failure(Runner.RunnerError.unableToOpenFile(filename: filename)))
        return
      }

      var lineByteArrayPointer: UnsafeMutablePointer<CChar>? = nil
      var lineCap: Int = 0
      var bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)

      while (bytesRead > 0) {
        let rawLine = String.init(cString: lineByteArrayPointer!)
        let line = rawLine.trimmingCharacters(in: CharacterSet.newlines)

        let instruction = try Instruction(from: line)
        position.move(using: instruction)

        bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)
      }

      completion(.success(position))
    } catch {
      completion(.failure(error))
    }
  }
}
