import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    @State private var currentLineNumber: Int = 1
    @State private var lineNumbers: [String] = (1...30).map { "\($0)" }
    @State private var isEditing: Bool = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.black
                    .ignoresSafeArea()
                    .ignoresSafeArea(.keyboard)

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        //EditButton(isEditing: $isEditing)
                            .padding(.trailing, 8)
                    }
                    .padding(.top, 8)

                    HStack(spacing: 0) {
                        ZStack(alignment: .topTrailing) {
                            CustomTextEditor(
                                text: .constant(lineNumbers.joined(separator: "\n")),
                                currentLineNumber: $currentLineNumber,
                                isEditing: $isEditing,
                                lineSpacing: 4,
                                isEditable: false,
                                highlightedLine: currentLineNumber,
                                fontSize: Constants.fontConstants.inputFont,
                                fontWeight: "Regular",
                                textAlignment: .right,
                                showLineHighlight: true

                            )
                            .frame(width: 30)
                            .padding(.trailing,0)
                            .background(Color.clear)
                            .multilineTextAlignment(.trailing)
                        }

                        CustomTextEditor(
                            text: $text,
                            currentLineNumber: $currentLineNumber,
                            isEditing: $isEditing,
                            lineSpacing: 4,
                            isEditable: true,
                            fontSize: Constants.fontConstants.inputFont,
                            fontWeight: "Medium",
                            showLineHighlight: true
                        )
                        .background(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 16)
                    .ignoresSafeArea(.keyboard)

                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: currentLineNumber) { oldValue, newValue in
            print("Current line: \(newValue)")
        }
        .ignoresSafeArea(.keyboard)

    }
}

#Preview {
    ContentView()
}
