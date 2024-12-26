//
//  Untitled.swift
//  Brackets
//
//  Created by R Trikha on 26/12/24.
//

import SwiftUI
import UIKit

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var currentLineNumber: Int
    @Binding var isEditing: Bool
    var lineSpacing: CGFloat = 4
    var isEditable: Bool = true
    var highlightedLine: Int? = nil
    var fontSize: CGFloat = Constants.fontConstants.inputFont
    var fontWeight: String = "Medium"
    var textAlignment: NSTextAlignment = .left
    var showLineHighlight: Bool = false
    
    private var font: UIFont {
        UIFont(name: "GeistMono-\(fontWeight)", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.tintColor = UIColor(Constants.colorConstants.accent)
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = isEditable ? 16 : 0
        textView.layoutManager.usesFontLeading = false
        
        textView.textColor = UIColor(Constants.colorConstants.darkFg)
        applyLineSpacing(to: textView)

        textView.text = text

        if showLineHighlight {
            let highlightView = UIView()
            highlightView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            highlightView.tag = 100
            textView.addSubview(highlightView)
            highlightView.isHidden = !isEditing
            
            let lineHeight = font.lineHeight + lineSpacing
            let yPosition = (lineHeight * CGFloat(max(0, currentLineNumber - 1))) + textView.textContainerInset.top - 2
            highlightView.frame = CGRect(
                x: textView.textContainerInset.left,
                y: yPosition,
                width: textView.bounds.width - (textView.textContainerInset.left + textView.textContainerInset.right),
                height: lineHeight
            )
        }

        if isEditing && isEditable {
            textView.becomeFirstResponder()
        }

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
            
            let pattern = "\\{ TODO  \\}|\\[ REMINDER  \\]"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(location: 0, length: uiView.text.count)
                let matches = regex.matches(in: uiView.text, options: [], range: range)
                
                for match in matches {
                    let matchedText = (uiView.text as NSString).substring(with: match.range)
                    if matchedText.contains("TODO") {
                        let keywordRange = NSRange(location: match.range.location + 2, length: 4)
                        uiView.textStorage.addAttributes([
                            .foregroundColor: UIColor(Constants.colorConstants.darkFg),
                            .font: font
                        ], range: match.range)
                        uiView.textStorage.addAttributes(Constants.styleConstants.todoStyle,
                                                     range: keywordRange)
                    } else if matchedText.contains("REMINDER") {
                        let keywordRange = NSRange(location: match.range.location + 2, length: 8)
                        uiView.textStorage.addAttributes([
                            .foregroundColor: UIColor(Constants.colorConstants.darkFg),
                            .font: font
                        ], range: match.range)
                        uiView.textStorage.addAttributes(Constants.styleConstants.reminderStyle,
                                                     range: keywordRange)
                    }
                }
            }
        }
        uiView.isEditable = isEditable
        
        if !isEditable {
            uiView.textColor = isEditing ? UIColor(Constants.colorConstants.lightFg) : UIColor(Constants.colorConstants.darkFg)
        }
        
        applyLineSpacing(to: uiView)

        if !isEditable && isEditing {
            updateLineColors(in: uiView)
        } else if !isEditable {
            uiView.textStorage.addAttributes([
                .foregroundColor: UIColor(Constants.colorConstants.darkFg),
                .font: font
            ], range: NSRange(location: 0, length: uiView.textStorage.length))
        }

        if showLineHighlight, let highlightView = uiView.viewWithTag(100) {
            highlightView.isHidden = !isEditing
            
            if isEditing {
                UIView.animate(withDuration: 0.05) {
                    let lineHeight = self.font.lineHeight + self.lineSpacing
                    let yPosition = (lineHeight * CGFloat(max(0, self.currentLineNumber - 1))) + uiView.textContainerInset.top - 2
                    highlightView.frame = CGRect(
                        x: uiView.textContainerInset.left,
                        y: yPosition,
                        width: uiView.bounds.width - (uiView.textContainerInset.left + uiView.textContainerInset.right),
                        height: lineHeight
                    )
                }
            }
        }

        if isEditing && isEditable {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor
        private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        
        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard parent.isEditable else { return }
            
            let selectedRange = textView.selectedRange
            let layoutManager = textView.layoutManager
            
            let text = textView.text ?? ""
            let cursorLocation = selectedRange.location
            
            let isAtNewLine = cursorLocation > 0 &&
                             text[text.index(text.startIndex, offsetBy: max(0, cursorLocation - 1))] == "\n"
            
            var lineNumber = 0
            if !text.isEmpty {
                let characterRange = NSRange(location: 0, length: cursorLocation)
                layoutManager.enumerateLineFragments(forGlyphRange: characterRange) { _, _, _, _, _ in
                    lineNumber += 1
                }
                
                if isAtNewLine {
                    lineNumber += 1
                }
            }
            
            parent.currentLineNumber = lineNumber
        }

        func textViewDidChange(_ textView: UITextView) {
            guard parent.isEditable else { return }
            parent.text = textView.text
            
            textViewDidChangeSelection(textView)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if parent.isEditable {
                parent.isEditing = true
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isEditing = false
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == Constants.bracketConstants.openingBrace {
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
                
                let todoText = Constants.bracketConstants.todoTemplate
                textView.textStorage.replaceCharacters(in: range, with: todoText)
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = parent.lineSpacing
                
                let templateRange = NSRange(location: range.location, length: todoText.count)
                textView.textStorage.addAttributes([
                    .foregroundColor: UIColor(Constants.colorConstants.accent),
                    .font: parent.font,
                    .paragraphStyle: paragraphStyle
                ], range: templateRange)
                
                let keywordRange = NSRange(location: range.location + 2, length: 4)
                var todoStyle = Constants.styleConstants.todoStyle
                todoStyle[.paragraphStyle] = paragraphStyle
                textView.textStorage.addAttributes(todoStyle, range: keywordRange)
                
                textView.selectedRange = NSRange(location: range.location + todoText.count - 2, length: 0)
                parent.text = textView.text
                
                return false
            } else if text == Constants.bracketConstants.openingBracket {
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
                
                let reminderText = Constants.bracketConstants.reminderTemplate
                textView.textStorage.replaceCharacters(in: range, with: reminderText)
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = parent.lineSpacing
                
                let templateRange = NSRange(location: range.location, length: reminderText.count)
                textView.textStorage.addAttributes([
                    .foregroundColor: UIColor(Constants.colorConstants.accent),
                    .font: parent.font,
                    .paragraphStyle: paragraphStyle
                ], range: templateRange)
                
                let keywordRange = NSRange(location: range.location + 2, length: 8)
                var reminderStyle = Constants.styleConstants.reminderStyle
                reminderStyle[.paragraphStyle] = paragraphStyle
                textView.textStorage.addAttributes(reminderStyle, range: keywordRange)
                
                textView.selectedRange = NSRange(location: range.location + reminderText.count - 2, length: 0)
                parent.text = textView.text
                
                return false
            }
            return true
        }
        
        private func createParagraphStyle() -> NSParagraphStyle {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = parent.lineSpacing
            style.alignment = parent.textAlignment
            return style
        }
    }

    private func applyLineSpacing(to textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = textAlignment

        let textColor = isEditable ? UIColor(Constants.colorConstants.lightFg) : UIColor(Constants.colorConstants.darkFg)
        textView.typingAttributes = [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: textColor,
            .kern: Constants.fontConstants.inputLineKerning

        ]
    }

    private func updateLineColors(in textView: UITextView) {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var characterCount = 0

        for (index, lineText) in lines.enumerated() {
            let range = NSRange(location: characterCount, length: lineText.count)
            characterCount += lineText.count + 1

            let color = (index + 1) == currentLineNumber ?
                UIColor(Constants.colorConstants.lightFg) :
                UIColor(Constants.colorConstants.darkFg)

            textView.textStorage.addAttributes([
                .foregroundColor: color,
                .font: font,
                .kern: Constants.fontConstants.inputLineKerning

            ], range: range)
        }
    }

    private func highlightLine(in textView: UITextView, line: Int) {
    }

}
