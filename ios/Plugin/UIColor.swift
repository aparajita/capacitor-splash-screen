import UIKit

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int, alpha: Int = 0xFF) {
    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: CGFloat(alpha) / 255.0
    )
  }

  convenience init(argb: UInt32) {
    self.init(
      red: CGFloat((argb >> 16) & 0xFF),
      green: CGFloat((argb >> 8) & 0xFF),
      blue: CGFloat(argb & 0xFF),
      alpha: CGFloat((argb >> 24) & 0xFF)
    )
  }

  convenience init?(fromHex: String) {
    var hexString = fromHex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(
      of: "#",
      with: ""
    )

    var rgba: UInt32 = 0

    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 1.0

    // Convert RGB[A] to RRGGBB[AA]
    if hexString.count == 3 || hexString.count == 4 {
      var rgbString = ""

      hexString.forEach { char in
        rgbString = rgbString + String(char) + String(char)
      }

      hexString = rgbString
    }

    guard Scanner(string: hexString).scanHexInt32(&rgba) else {
      return nil
    }

    if hexString.count == 6 {
      // RRGGBB
      red = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
      green = CGFloat((rgba & 0x00FF00) >> 8) / 255.0
      blue = CGFloat(rgba & 0x0000FF) / 255.0

    } else if hexString.count == 8 {
      // RRGGBBAA
      red = CGFloat((rgba & 0xFF00_0000) >> 24) / 255.0
      green = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
      blue = CGFloat((rgba & 0x0000FF00) >> 8) / 255.0
      alpha = CGFloat(rgba & 0x000000FF) / 255.0

    } else {
      return nil
    }

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  static func from(string: String) -> UIColor? {
    switch string {
      case "systemBackground":
        if #available(iOS 13.0, *) {
          return UIColor.systemBackground
        } else {
          return UIColor.white
        }

      case "systemText":
        if #available(iOS 13.0, *) {
          return UIColor.label
        } else {
          return UIColor.black
        }

      default:
        return UIColor(fromHex: string)
    }
  }
}
