import Foundation
import SwiftUI

enum Constants {
    struct debug {
        static let showBounds = true
    }
    
    struct fontConstants {
        static let inputFont: CGFloat = 14
        static let inputLineKerning: CGFloat = -0.5

    }
    
    struct bracketConstants {
        static let openingBrace: String = "{"
        static let closingBrace: String = "}"
        static let todoTemplate: String = "{ TODO  }"
        static let openingBracket: String = "["
        static let closingBracket: String = "]"
        static let reminderTemplate: String = "[ REMINDER  ]"
        static let todoKeyword = "TODO"
        static let reminderKeyword = "REMINDER"
        static let todoKeywordRange = NSRange(location: 2, length: 4)
        static let reminderKeywordRange = NSRange(location: 2, length: 8)
    }

    struct styleConstants {
        static let baselineHeight: CGFloat = 13
        
        static let todoStyle: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(colorConstants.lightFg),
            .backgroundColor: UIColor(colorConstants.accent),
            .font: UIFont(name: "GeistMono-Bold", size: fontConstants.inputFont) ?? .boldSystemFont(ofSize: fontConstants.inputFont),
            .baselineOffset: (baselineHeight - fontConstants.inputFont) / 2
        ]
        
        static let reminderStyle: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(colorConstants.lightFg),
            .backgroundColor: UIColor(colorConstants.accent),
            .font: UIFont(name: "GeistMono-Bold", size: fontConstants.inputFont) ?? .boldSystemFont(ofSize: fontConstants.inputFont),
            .baselineOffset: (baselineHeight - fontConstants.inputFont) / 2
        ]
        
        static let bracketStyle: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(colorConstants.darkFg),
            .backgroundColor: UIColor.clear,
        ]
        
        static let templateMargin: CGFloat = 1
    }
    
    struct colorConstants {
        static let darkBg: Color = Color.black
        static let darkFg: Color = Color(#colorLiteral(red: 0.3019607365, green: 0.3019607365, blue: 0.3019607365, alpha: 1))
        static let lightFg: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        static let accent: Color = Color(#colorLiteral(red: 0.9999960065, green: 0.4939998984, blue: 0.3059999943, alpha: 1))
        static let darkAccent = Color(#colorLiteral(red: 0.2186835408, green: 0.1084509268, blue: 0.04107496887, alpha: 1))
    }

    struct viewModifiers {
        static let drawBounds = Border(color: .red, width: 1)
    }
}

struct Border: ViewModifier {
    let color: Color
    let width: CGFloat

    func body(content: Content) -> some View {
        if Constants.debug.showBounds {
            content.border(color, width: width)
        } else {
            content
        }
    }
}

extension View {
    func drawBounds() -> some View {
        modifier(Constants.viewModifiers.drawBounds)
    }
}
