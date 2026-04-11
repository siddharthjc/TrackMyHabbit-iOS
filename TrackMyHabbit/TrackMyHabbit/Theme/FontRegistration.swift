import CoreText
import Foundation

enum FontRegistration {
    static func registerBundledFonts() {
        guard let fontsURL = Bundle.main.url(forResource: "Fonts", withExtension: nil, subdirectory: "Theme") else {
            return
        }

        guard let enumerator = FileManager.default.enumerator(at: fontsURL, includingPropertiesForKeys: nil) else {
            return
        }

        for case let url as URL in enumerator {
            guard ["ttf", "otf", "ttc"].contains(url.pathExtension.lowercased()) else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

