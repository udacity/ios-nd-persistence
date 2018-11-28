//
//  Pathifier.swift
//  Mooskine
//
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreText

internal struct Pathifier {
    /// Creates a UIBezierPath from a supplied attributed string and font (the
    /// font will be applied to the entire attributed string).
    static func makeBezierPath(for attributedString: NSAttributedString, withFont font: UIFont) -> UIBezierPath {
        // To generate the bezier path, we'll break the attributed string into
        // a series of `NSGlyph`s using TextKit, and use a CoreText function to
        // create individual individual paths for each glyph.
        
        // Apply the supplied font
        let text = NSMutableAttributedString(string: attributedString.string)
        text.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, text.length))
        
        // Create a NSLayoutManager to generate the glyphs
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer()
        let textStorage = NSTextStorage(attributedString: text)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        // Use the layout manager to loop through the glyphs, adding to a bezier
        // path as we go
        let path = UIBezierPath()
        let font = CTFontCreateWithFontDescriptor(font.fontDescriptor, font.pointSize, nil)
        for glyphIndex in 0 ..< layoutManager.numberOfGlyphs {
            let glyph = layoutManager.cgGlyph(at: glyphIndex)
            let position = layoutManager.location(forGlyphAt: glyphIndex)
            if let glyphPath = CTFontCreatePathForGlyph(font, glyph, nil) {
                let glyphBezierPath = UIBezierPath(cgPath: glyphPath)
                glyphBezierPath.apply(CGAffineTransform(translationX: position.x, y: 0))
                path.append(glyphBezierPath)
            }
        }
        
        return path
    }
    
    /// Generate an image for an attributed string, using `makeBezierPath(for:withFont:)`
    static func makeImage(for attributedString: NSAttributedString, withFont font: UIFont, withPatternImage patternImage: UIImage) -> UIImage {
        let path = makeBezierPath(for: attributedString, withFont: font)
        let bounds = path.bounds
        let pad = CGSize(width: 4, height: 6) // Add some padding so the wide lines don't clip - should figure out the metrics for this via Core Text. :)
        let size = CGSize(width: bounds.size.width + bounds.origin.x + pad.width, height: bounds.size.height + pad.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Flip the orientation vertically
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -size.height)
        
        // Adjust positioning for the padding
        context?.translateBy(x: -pad.width / 2, y: pad.height / 2)
        
        // Draw the path
        context?.setFillColor(UIColor(patternImage: patternImage).cgColor)
        path.fill()
        context?.setStrokeColor(UIColor.black.cgColor)
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    static func makeMutableAttributedString(for attributedString: NSAttributedString, withFont font: UIFont, withPatternImage patternImage: UIImage) -> NSMutableAttributedString {
        
        // converts text to image using patternimage
        let image = Pathifier.makeImage(for: attributedString, withFont: font, withPatternImage: patternImage)
        
        // creates a text attachment with the image
        let attachment = NSTextAttachment()
        attachment.image = image
        
        // converts attachment to mutable attributed string
        let attachmentAsText = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        return attachmentAsText
    }
}
