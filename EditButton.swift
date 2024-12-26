import SwiftUI

struct EditButton: View {
    @Binding var isEditing: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                isEditing.toggle()
            }
        }) {
            Image(systemName: isEditing ? "keyboard.fill" : "keyboard")
                .foregroundColor(isEditing ? Constants.colorConstants.accent : Constants.colorConstants.darkFg)
                .font(.system(size: Constants.fontConstants.inputFont))
                .frame(width: 32, height: 32)
                .background(Constants.colorConstants.darkBg)
                .cornerRadius(8)
        }
    }
}

// End of file
