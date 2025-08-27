import Foundation
import SwiftUI

struct PlanView: View {
    let plan: Plan

    var body: some View {
        VStack {
            Text(plan.name)
                .font(.headline)
            Divider()

//            Text(plan.price)
//                .font(.system(size: 36, weight: .bold))
//            + Text(plan.period)
//                .font(.subheadline)

//            Button("Buy plan") {
//                // Handle purchase
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(plan.name == "Essential" ? Color.blue : Color.gray)
//            .foregroundColor(.white)
//            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Features")
                    .font(.headline)

                ForEach(Array(plan.features.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        if let value = plan.features[key] as? Bool {
                            Image(systemName: value ? "checkmark" : "minus")
                        } else if let value = plan.features[key] as? String {
                            Text(value)
                        }
                    }
                }
            }
            .padding(.top)
        }
        .padding()
        .cornerRadius(12)
    }
}
