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
    let hexString = fromHex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(
      of: "#",
      with: ""
    )

    var argb: UInt32 = 0

    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 1.0

    guard Scanner(string: hexString).scanHexInt32(&argb) else {
      return nil
    }

    if hexString.count == 6 {
      red = CGFloat((argb & 0xFF0000) >> 16) / 255.0
      green = CGFloat((argb & 0x00FF00) >> 8) / 255.0
      blue = CGFloat(argb & 0x0000FF) / 255.0

    } else if hexString.count == 8 {
      red = CGFloat((argb & 0xFF00_0000) >> 24) / 255.0
      green = CGFloat((argb & 0x00FF0000) >> 16) / 255.0
      blue = CGFloat((argb & 0x0000FF00) >> 8) / 255.0
      alpha = CGFloat(argb & 0x000000FF) / 255.0

    } else {
      return nil
    }

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
