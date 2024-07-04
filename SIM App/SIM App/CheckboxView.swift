import SwiftUI

struct CheckboxView: View {
    @Binding var isChecked: Bool
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            isChecked.toggle()
            onTap?()
        }) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .foregroundColor(isChecked ? .blue : .secondary)
        }
    }
}
