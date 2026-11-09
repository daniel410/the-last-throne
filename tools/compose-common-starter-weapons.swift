import AppKit
let dir=CommandLine.arguments[1]
let image=NSImage(size:NSSize(width:2000,height:800))
image.lockFocus()
NSColor(calibratedRed:0.11,green:0.125,blue:0.15,alpha:1).setFill();NSBezierPath(rect:NSRect(x:0,y:0,width:2000,height:800)).fill()
let keys=["knight","dwarf","elf","mage"], names=["Tempered Sword","Tempered Axe","Tempered Bow","Tempered Staff"]
for i in 0..<4 {
 let src=NSImage(contentsOfFile:dir+"/"+keys[i]+".png")!
 src.draw(in:NSRect(x:i*500,y:100,width:500,height:700))
 let style=NSMutableParagraphStyle();style.alignment = .center
 let title:[NSAttributedString.Key:Any]=[.font:NSFont.systemFont(ofSize:24),.foregroundColor:NSColor.white,.paragraphStyle:style]
 let detail:[NSAttributedString.Key:Any]=[.font:NSFont.systemFont(ofSize:19),.foregroundColor:NSColor.lightGray,.paragraphStyle:style]
 (names[i] as NSString).draw(in:NSRect(x:i*500,y:54,width:500,height:32),withAttributes:title)
 ("Common  |  Lv1  |  Attack +3" as NSString).draw(in:NSRect(x:i*500,y:17,width:500,height:27),withAttributes:detail)
}
image.unlockFocus()
let rep=NSBitmapImageRep(data:image.tiffRepresentation!)!
try rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:dir+"/common-starter-weapons.png"))
