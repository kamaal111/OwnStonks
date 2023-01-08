//
//  EnviroEnvironmentnmentTests.swift
//
//
//  Created by Kamaal M Farah on 08/01/2023.
//


public enum Environment {
    public enum CommandLineArguments: String {
        case skipForexCaching = "skip_forex_caching"

        public var enabled: Bool {
            CommandLine.arguments.contains(rawValue)
        }

        public static func inject(_ argument: CommandLineArguments) {
            guard !argument.enabled else { return }

            CommandLine.arguments.append(argument.rawValue)
        }

        public static func remove(_ argument: CommandLineArguments) {
            guard let index = CommandLine.arguments.firstIndex(of: argument.rawValue) else { return }

            CommandLine.arguments.remove(at: index)
        }
    }
}
