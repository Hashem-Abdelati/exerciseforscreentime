//
//  SetupViewShortcuts.swift
//  exerciseforscreentime
//
//  Created by Hashem Abdelati on 2/2/26.
//
import SwiftUI

struct SetupViewShortcuts: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shortcuts Setup")
                .font(.title2).bold()

            Text("Create a Shortcuts Personal Automation:")
            Text("1) Shortcuts → Automation → + → Create Personal Automation")
            Text("2) App → Is Opened → pick the apps you want to gate")
            Text("3) Add Action → Open URL → exercisetime://workout")
            Text("4) Turn off Ask Before Running (if available)")

            Divider().padding(.vertical, 8)

            Text("Deep link to test:")
                .font(.headline)
            Text("exercisetime://workout")
                .font(.system(.body, design: .monospaced))
        }
        .padding()
    }
}
