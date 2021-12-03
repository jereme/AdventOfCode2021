#!/usr/bin/env swift

import Foundation

do {
  let runner = try Runner(arguments: CommandLine.arguments)
  runner.start()

  print("Final Position: \(runner.horiztonalPosition), \(runner.verticalPosition)")
  print("Result == \(runner.horiztonalPosition * runner.verticalPosition)")

} catch RunnerError.invalidUsage {
  print("Command: problem1 <filename>")

} catch RunnerError.fileNotFound(let filename) {
  print("File not found: \(filename)")

} catch RunnerError.unableToOpenFile(let filename) {
  print("Unable to open file: \(filename)")
}

// MARK: -

enum RunnerError: Error {
  case invalidUsage
  case fileNotFound(filename: String)
  case unableToOpenFile(filename: String)
  case invalidInstruction(instruction: String)
}

private enum Direction: String {
  case forward
  case up
  case down
}

final class Runner {
  let fileManager = FileManager.default
  let filePointer: UnsafeMutablePointer<FILE>
  let filename: String

  private(set) var verticalPosition = 0
  private(set) var horiztonalPosition = 0

  init(arguments: [String]) throws {
    guard arguments.count == 2 else {
      throw RunnerError.invalidUsage
    }

    self.filename = arguments[1]

    guard fileManager.fileExists(atPath: filename) else {
      throw RunnerError.fileNotFound(filename: filename)
    }

    guard let filePointer = fopen(filename,"r") else {
      throw RunnerError.unableToOpenFile(filename: filename)
    }

    self.filePointer = filePointer

    print("Filename \(filename)")
  }

  deinit {
    fclose(filePointer)
  }

  func start() {
    var lineByteArrayPointer: UnsafeMutablePointer<CChar>? = nil
    var lineCap: Int = 0
    var bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)

    while (bytesRead > 0) {
      let lineAsString = String.init(cString: lineByteArrayPointer!)
      let instruction = lineAsString.trimmingCharacters(in: CharacterSet.newlines)

      do {
        try processInstruction(instruction)
      } catch RunnerError.invalidInstruction(let instruction) {
        print("Invalid instruction: \(instruction)")
      } catch {
        print("Unknown error on instruction: \(instruction): \(error)")
      }

      bytesRead = getline(&lineByteArrayPointer, &lineCap, filePointer)
    }
  }

  private func processInstruction(_ instruction: String) throws {
    let components = instruction.components(separatedBy: " ")

    guard
      components.count == 2,
      let direction = Direction(rawValue: components[0]),
      let moves = Int(components[1])
    else {
      throw RunnerError.invalidInstruction(instruction: instruction)
    }

    move(direction, moves: moves)
  }

  private func move(_ direction: Direction, moves: Int) {
    switch direction {
    case .forward:
      horiztonalPosition += moves

    case .up:
      verticalPosition -= moves

    case .down:
      verticalPosition += moves
    }
  }
}
