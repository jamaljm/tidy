// Draws Tidy's app icon: a white chat bubble with a sparkle, on a green tile.
// Usage: swift icon.swift out.png

import AppKit

let S: CGFloat = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(S), pixelsHigh: Int(S),
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

func rgb(_ hex: Int, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: a)
}

// Tile (standard macOS icon grid: 824pt tile centered in 1024).
let tile = NSRect(x: 100, y: 100, width: 824, height: 824)
let tilePath = NSBezierPath(roundedRect: tile, xRadius: 186, yRadius: 186)
NSGraphicsContext.saveGraphicsState()
let drop = NSShadow()
drop.shadowColor = rgb(0x000000, 0.28)
drop.shadowOffset = NSSize(width: 0, height: -12)
drop.shadowBlurRadius = 28
drop.set()
rgb(0x10B981).setFill()
tilePath.fill()
NSGraphicsContext.restoreGraphicsState()
NSGradient(starting: rgb(0x34D399), ending: rgb(0x047857))!.draw(in: tilePath, angle: -90)

// Soft top highlight.
NSGraphicsContext.saveGraphicsState()
tilePath.addClip()
NSGradient(starting: rgb(0xFFFFFF, 0.18), ending: rgb(0xFFFFFF, 0))!
    .draw(in: NSRect(x: 100, y: 560, width: 824, height: 364), angle: -90)
NSGraphicsContext.restoreGraphicsState()

// Chat bubble with a tail at the bottom-left.
let bubbleRect = NSRect(x: 232, y: 330, width: 560, height: 420)
let bubble = NSBezierPath(roundedRect: bubbleRect, xRadius: 170, yRadius: 170)
let tail = NSBezierPath()
tail.move(to: NSPoint(x: 300, y: 420))
tail.curve(to: NSPoint(x: 262, y: 250), controlPoint1: NSPoint(x: 300, y: 330), controlPoint2: NSPoint(x: 290, y: 280))
tail.curve(to: NSPoint(x: 450, y: 345), controlPoint1: NSPoint(x: 340, y: 270), controlPoint2: NSPoint(x: 410, y: 300))
tail.close()
bubble.append(tail)

NSGraphicsContext.saveGraphicsState()
let bubbleShadow = NSShadow()
bubbleShadow.shadowColor = rgb(0x064E3B, 0.35)
bubbleShadow.shadowOffset = NSSize(width: 0, height: -10)
bubbleShadow.shadowBlurRadius = 24
bubbleShadow.set()
rgb(0xFFFFFF).setFill()
bubble.fill()
NSGraphicsContext.restoreGraphicsState()

// Four-point sparkle.
func sparkle(_ c: NSPoint, _ r: CGFloat) -> NSBezierPath {
    let p = NSBezierPath()
    let k = r * 0.14
    p.move(to: NSPoint(x: c.x, y: c.y + r))
    p.curve(to: NSPoint(x: c.x + r, y: c.y), controlPoint1: NSPoint(x: c.x + k, y: c.y + k), controlPoint2: NSPoint(x: c.x + k, y: c.y + k))
    p.curve(to: NSPoint(x: c.x, y: c.y - r), controlPoint1: NSPoint(x: c.x + k, y: c.y - k), controlPoint2: NSPoint(x: c.x + k, y: c.y - k))
    p.curve(to: NSPoint(x: c.x - r, y: c.y), controlPoint1: NSPoint(x: c.x - k, y: c.y - k), controlPoint2: NSPoint(x: c.x - k, y: c.y - k))
    p.curve(to: NSPoint(x: c.x, y: c.y + r), controlPoint1: NSPoint(x: c.x - k, y: c.y + k), controlPoint2: NSPoint(x: c.x - k, y: c.y + k))
    p.close()
    return p
}

let big = sparkle(NSPoint(x: 490, y: 530), 150)
let small = sparkle(NSPoint(x: 640, y: 645), 58)
let tiny = sparkle(NSPoint(x: 650, y: 430), 34)
for s in [big, small, tiny] {
    NSGradient(starting: rgb(0x10B981), ending: rgb(0x047857))!.draw(in: s, angle: -90)
}

NSGraphicsContext.restoreGraphicsState()
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
