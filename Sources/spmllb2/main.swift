// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

import ArgumentParser
import NIO
import llbuild2
import LLBBuildSystem
import LLBBuildSystemUtil
import Foundation
import TSCBasic
import LLBSwiftBuild
import TSCLibc

struct SPMLLBTool: ParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [
        ]
    )

    func cwd() throws -> AbsolutePath {
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw StringError("unable to find current working directory")
        }
        return cwd
    }

    func run() throws {
        let group = MultiThreadedEventLoopGroup(
            numberOfThreads: ProcessInfo.processInfo.processorCount
        )

        let cwd = try self.cwd()
        let buildDir = cwd.appending(component: ".build")
        let db = LLBFileBackedCASDatabase(
            group: group,
            path: buildDir.appending(component: "cas")
        )
        let fnCache = LLBFileBackedFunctionCache(
            group: group,
            path: buildDir.appending(component: "cache")
        )

        let executor = LLBLocalExecutor(
            outputBase: buildDir.appending(component: "outputs")
        )

        let engineContext = LLBBasicBuildEngineContext(
            group: group,
            db: db,
            executor: executor
        )
        let buildSystemDelegate = SwiftBuildSystemDelegate(
            engineContext: engineContext
        )

        let engine = LLBBuildEngine(
            engineContext: engineContext,
            buildFunctionLookupDelegate: buildSystemDelegate,
            configuredTargetDelegate: buildSystemDelegate,
            ruleLookupDelegate: buildSystemDelegate,
            registrationDelegate: buildSystemDelegate,
            executor: executor,
            functionCache: fnCache
        )

        let request = BuildRequest(rootID: .init(), targets: [])
        let result = try engine.build(request).wait()
        print(result)
    }
}

SPMLLBTool.main()
