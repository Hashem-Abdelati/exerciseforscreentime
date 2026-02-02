//
//  GateIntents.swift
//  exerciseforscreentime
//
//  Created by Hashem Abdelati on 2/2/26.
//
import AppIntents
import Foundation

struct GateStore {
    static let key = "minutesRemaining"

    static func getMinutes() -> Int {
        UserDefaults.standard.integer(forKey: key)
    }

    static func add(_ minutes: Int) {
        let current = getMinutes()
        UserDefaults.standard.set(current + minutes, forKey: key)
    }

    /// returns (allowed, remaining)
    static func consume(_ minutes: Int) -> (Bool, Int) {
        let current = getMinutes()
        guard current >= minutes else { return (false, current) }
        let newVal = current - minutes
        UserDefaults.standard.set(newVal, forKey: key)
        return (true, newVal)
    }
}

struct GetBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Remaining Minutes"
    static var description = IntentDescription("Returns the number of minutes remaining in your exercise time bank.")

    func perform() async throws -> some ReturnsValue<Int> {
        .result(value: GateStore.getMinutes())
    }
}

struct ConsumeMinutesIntent: AppIntent {
    static var title: LocalizedStringResource = "Consume Minutes"
    static var description = IntentDescription("Consumes minutes from your time bank. Returns whether you were allowed.")

    @Parameter(title: "Minutes to Consume")
    var minutes: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Consume \(\.$minutes) minutes")
    }

    func perform() async throws -> some ReturnsValue<Bool> & ProvidesDialog {
        let (allowed, remaining) = GateStore.consume(minutes)
        if allowed {
            return .result(value: true, dialog: "Allowed. \(remaining) minutes remaining.")
        } else {
            return .result(value: false, dialog: "Not allowed. \(remaining) minutes remaining.")
        }
    }
}

