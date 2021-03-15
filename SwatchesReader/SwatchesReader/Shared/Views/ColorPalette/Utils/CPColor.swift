//  CPColor.swift
//  SwatchesReader
//
//  Created by Viktor Goltvyanytsya on 15.01.2021.
//

import Foundation

import SwiftUI
import os.log


#if canImport(UIKit)
import UIKit
typealias NativeColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias NativeColor = NSColor
#endif


extension NativeColor {
    
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        if ( getRed(&r, green: &g, blue: &b, alpha: &a) ) {
            return (r, g, b, a)
        }
        
        var w: CGFloat = 0
        
        if ( getWhite(&w, alpha:&a) ) {
            return (w, w, w, a)
        }
        
        return (0, 0, 0, 0)
    }
    
    var hexint: Int {
        let clr = self.rgba
        
        let r: CGFloat = min(max(clr.r, 0.0), 1.0)
        let g: CGFloat = min(max(clr.g, 0.0), 1.0)
        let b: CGFloat = min(max(clr.b, 0.0), 1.0)
        
        return (((Int)(round(r * 255.0))) << 16)
            | (((Int)(round(g * 255.0))) << 8)
            | (((Int)(round(b * 255.0))))
    }
    
    var hexstr: String {
        return String(format:"%06X", self.hexint)
    }
}

extension Color {
    #if canImport(UIKit)
    var asNative: UIColor { UIColor(self) }
    #elseif canImport(AppKit)
    var asNative: NSColor { NSColor(self) }
    #endif
    
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        return asNative.rgba
    }
    
    var hexstr: String {
        return asNative.hexstr
    }
    
    var hexint: Int {
        return asNative.hexint
    }
}

private extension String {
    func round(_ decimals:Int) -> String {
        let roundingBehaviour: NSDecimalNumberHandler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain,
                                                                               scale: Int16(decimals),
                                                                               raiseOnExactness: false,
                                                                               raiseOnOverflow: false,
                                                                               raiseOnUnderflow: false,
                                                                               raiseOnDivideByZero: false)
        
        return NSDecimalNumber(string:self).rounding(accordingToBehavior: roundingBehaviour).description
    }
}

@propertyWrapper
struct CPColorClamped<Value : Comparable> {
    private var value: Value
    private var range: ClosedRange<Value>
    
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        value = wrappedValue
        self.range = range
    }
    
    var wrappedValue: Value {
        get { value }
        set {
            value = min(max(range.lowerBound, newValue), range.upperBound)
        }
    }
    
}

struct CPColorRGBA {
    @CPColorClamped(0...1.0)
    var r: CGFloat = 0.0
    
    @CPColorClamped(0...1.0)
    var g: CGFloat = 0.0
    
    @CPColorClamped(0...1.0)
    var b: CGFloat = 0.0
    
    @CPColorClamped(0...1.0)
    var a: CGFloat = 0.0
}

// ranges for in and out:
// L 0...1
// a = -1.28...1.27
// b = -1.28...1.27
// all other values: 0.0 ... 1.0

struct CPColor: Identifiable  {
    
    public var id = UUID()
    
    private(set) var raw: CPColorRGBA = CPColorRGBA(r:0.0, g: 0.0, b: 0.0, a: 1.0)
    
    private let defaultAlpha: CGFloat = 1.0
    
    // multiplier for rgb description
    private let strn: CGFloat = 255.0
    
    // multiplier for all other descriptions
    private let strm: CGFloat = 100.0
    
    public let rgbWhite: (r: CGFloat, g: CGFloat, b: CGFloat) = (r: 1.0, g: 1.0, b: 1.0)
    public let rgbBlack: (r: CGFloat, g: CGFloat, b: CGFloat) = (r: 0.0, g: 0.0, b: 1.0)
    
    init(  ) {
        self.rgba = (r: CGFloat(0.0), g: CGFloat(0.0), b: CGFloat(0.0), a:defaultAlpha )
    }
    
    init( rgba:(r: CGFloat, g: CGFloat, b: CGFloat, a:CGFloat) ) {
        self.rgba = rgba
    }
    
    init( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) {
        self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:defaultAlpha )
    }
    
    init( hexint: Int ) {
        let channels = hexint2rgb(hexint: hexint)
        self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:defaultAlpha)
    }
    
    init( white: CGFloat ) {
        let channels = white2rgb(w: white)
        self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:defaultAlpha)
    }
    
    // wrapper around wrapper - self.raw clamped values
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        set {
            self.raw = CPColorRGBA(r: newValue.r, g: newValue.g, b: newValue.b, a:newValue.a)
        }
        get {
            return (r: raw.r, g: raw.g, b: raw.b, a: raw.a )
        }
    }
    
    var rgb: (r: CGFloat, g: CGFloat, b: CGFloat) {
        set {
            self.rgba = (r: newValue.r, g: newValue.g, b: newValue.b, a:rgba.a)
        }
        get {
            return (r: rgba.r, g: rgba.g, b: rgba.b )
        }
    }
    
    var alpha: CGFloat {
        set {
            self.rgba.a = newValue
        }
        get {
            return rgba.a
        }
    }
    
    var hexint: Int {
        set {
            let channels = hexint2rgb(hexint: newValue)
            self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:rgba.a)
        }
        get {
            let channels = self.rgb
            return rgb2hexint(rgb:channels)
        }
    }
    
    var hexstr: String {
        let channels:Int =  self.hexint
        return String(format:"%06X", channels)
    }
    
    var rgbstr: String {
        let channels = self.rgba
        let r: CGFloat = channels.r*strn
        let g: CGFloat = channels.g*strn
        let b: CGFloat = channels.b*strn
        return String(format:"R:%.0f G:%.0f B:%.0f", r, g, b)
    }
    
    var white: CGFloat {
        set {
            let channels = white2rgb(w:newValue)
            self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:rgba.a)
        }
        get {
            return rgb2white(rgb:self.rgb)
        }
    }
    
    var whitestr: String {
        let w:String = String(format: "%f", self.white*strm).round(3)
        return "W:"+w
    }
    
    public func rgb2hexint( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) ->Int {
        let r: CGFloat = min(max(rgb.r, 0.0), 1.0)
        let g: CGFloat = min(max(rgb.g, 0.0), 1.0)
        let b: CGFloat = min(max(rgb.b, 0.0), 1.0)
        
        return (((Int)(round(r * 255.0))) << 16)
            | (((Int)(round(g * 255.0))) << 8)
            | (((Int)(round(b * 255.0))))
    }
    
    public func hexint2rgb(hexint: Int)->(r: CGFloat, g: CGFloat, b: CGFloat){
        let r: Int = (hexint >> 16) & 0xFF
        let g: Int = (hexint >> 8) & 0xFF
        let b: Int = (hexint) & 0xFF
        return (r: CGFloat(r), g: CGFloat(g), b: CGFloat(b) )
    }
    
    public func rgb2white( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) -> CGFloat {
        let colorMax: CGFloat = max(max(rgb.r,rgb.g),rgb.b)
        let colorMin: CGFloat = min(min(rgb.r,rgb.g),rgb.b)
        
        return (colorMax+colorMin)/2.0
    }
    
    public func white2rgb(w: CGFloat)->(r: CGFloat, g: CGFloat, b: CGFloat){
        return (r: w, g: w, b: w)
    }
    
}

// Color, UIColor, NSColor
extension CPColor {
    
    init(color: Color) {
        self.rgba = color.rgba
    }
    
    init(nativeColor: NativeColor) {
        self.rgba = nativeColor.rgba
    }
    
    var color: Color {
        set {
            self.rgba = newValue.rgba
        }
        get {
            let r: Double = Double(rgba.r)
            let g: Double = Double(rgba.g)
            let b: Double = Double(rgba.b)
            let a: Double = Double(rgba.a)
            return Color(red:r, green:g, blue:b, opacity:a)
        }
    }
    
    var nativeColor: NativeColor {
        set {
            self.rgba = newValue.rgba
        }
        get {
            return self.color.asNative
        }
    }
    
}

// HSV
extension CPColor {
    
    init( hsv:(h: CGFloat, s: CGFloat, v: CGFloat ) ) {
        let channels = hsv2rgb(hsv:hsv)
        self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:defaultAlpha)
    }
    
    var hsv: (h: CGFloat, s: CGFloat, v: CGFloat ) {
        set {
            let channels = hsv2rgb(hsv:newValue)
            self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:rgba.a)
        }
        get {
            return rgb2hsv(rgb:self.rgb)
        }
        
    }
    
    var hsvstr: String {
        let vals = self.hsv
        let fh: String = String(format: "%.0f", vals.h*strm)
        let fs: String = String(format: "%.0f", vals.s*strm)
        let fv: String = String(format: "%.0f", vals.v*strm)
        return "H:"+fh+" S:"+fs+" V:"+fv
    }
    
    public func hsv2rgb( hsv:(h: CGFloat, s: CGFloat, v: CGFloat) ) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        
        if( hsv.v == 0.0 ){
            return rgbBlack
        }
        
        if( hsv.v == 1.0 && hsv.s==0.0){
            return rgbWhite
        }
        
        var rem1: CGFloat = 0.0
        var rem2: CGFloat = 0.0
        var rem3: CGFloat = 0.0
        var rem4: CGFloat = 0.0
        
        if(hsv.h != 1.0){
            rem4 = (hsv.h*360.0)/60.0
        }
        
        let rem5: CGFloat = rem4.rounded(.down)
        let rem7: CGFloat = rem4-rem5
        let rem8: CGFloat = (1.0-hsv.s)*hsv.v
        
        rem3 = (1.0-hsv.s*rem7)*hsv.v
        let rem6: CGFloat = (1.0-hsv.s*(1.0-rem7))*hsv.v
        
        switch (rem5){
        case 0.0 :
            rem1 = hsv.v
            rem2 = rem6
            rem3 = rem8
        case 1.0 :
            rem1 = rem3
            rem2 = hsv.v
            rem3 = rem8
        case 2.0 :
            rem1 = rem8
            rem2 = hsv.v
            rem3 = rem6
        case 3.0 :
            rem1 = rem8
            rem2 = rem3
            rem3 = hsv.v
        case 4.0 :
            rem1 = rem6
            rem2 = rem8
            rem3 = hsv.v
        case 5.0 :
            rem1 = hsv.v
            rem2 = rem8
            // rem3 = rem3
        default :
            rem1 = 0.0
            rem2 = 0.0
            rem3 = 0.0
        }
        
        return (r: rem1, g: rem2, b: rem3)
    }
    
    public func rgb2hsv( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        var rem0: CGFloat = 0.0
        
        let rem3: CGFloat = max( max(rgb.r, rgb.g), rgb.b)
        let rem4: CGFloat = min( min(rgb.r, rgb.g), rgb.b)
        var rem1: CGFloat = (rem3-rem4)/rem3
        let rem2: CGFloat = rem3
        
        if(rem1 == 0.0){
            rem0 = 0.0
        }else{
            let rem5: CGFloat = rem3-rem4
            if(rem5==0.0){
                rem0 = 0.0
                rem1 = 0.0
            }else{
                let rm: CGFloat = (rem3-rgb.r)/rem5
                let gm: CGFloat = (rem3-rgb.g)/rem5
                let bm: CGFloat = (rem3-rgb.b)/rem5
                if (rgb.r==rem3&&rgb.g==rem4) {
                    rem0 = 5.0+bm
                } else {
                    if( (rgb.r == rem3) && (rgb.g != rem4) ) {
                        rem0 = 1.0-gm
                    }else{
                        if(rgb.g==rem3&&rgb.b==rem4){
                            rem0 = rm+1.0
                        }else{
                            if(rgb.g == rem3 && rgb.b != rem4) {
                                rem0 = 3.0-bm
                            }else{
                                if (rgb.r == rem4){
                                    rem0 = 3.0+gm
                                } else {
                                    rem0 = 5.0-rm
                                }
                            }
                        }
                    }
                }
                rem0 *= 60.0
            }
        }
        
        if (rem0>=360.0){
            rem0 -= 360.0
        }
        
        
        return (h: rem0/360.0, s: rem1, v: rem2)
    }
    
    public func hsv2white( hsv:(h: CGFloat, s: CGFloat, v: CGFloat) )-> CGFloat{
        if(hsv.v==0.0){
            return 0.0
        }
        
        if(hsv.v==1.0 && hsv.s==0.0){
            return 1.0
        }
        
        var rem1: CGFloat = 0.0
        var rem2: CGFloat = 0.0
        var rem3: CGFloat = 0.0
        var rem4: CGFloat = 0.0
        
        if( hsv.h != 1.0 ){
            rem4 = (hsv.h*360.0)/60.0
        }
        
        let rem5: CGFloat = rem4.rounded(.down)
        let rem7: CGFloat = rem4-rem5
        let rem8: CGFloat = (1.0-hsv.s)*hsv.v
        
        rem3 = (1.0-hsv.s*rem7)*hsv.v
        let rem6: CGFloat = (1.0-hsv.s*(1.0-rem7))*hsv.v
        
        switch (rem5){
        case 0.0 :
            rem1 = hsv.v
            rem2 = rem6
            rem3 = rem8
        case 1.0 :
            rem1 = rem3
            rem2 = hsv.v
            rem3 = rem8
        case 2.0 :
            rem1 = rem8
            rem2 = hsv.v
            rem3 = rem6
        case 3.0 :
            rem1 = rem8
            rem2 = rem3
            rem3 = hsv.v
        case 4.0 :
            rem1 = rem6
            rem2 = rem8
            rem3 = hsv.v
        case 5.0 :
            rem1 = hsv.v
            rem2 = rem8
            //rem3 = rem3
        default :
            rem1 = 0.0
            rem2 = 0.0
            rem3 = 0.0
        }
        
        return rgb2white( rgb:(r:rem1, g:rem2, b:rem3) )
    }
    
    public func white2hsv(w: CGFloat)->(h: CGFloat, s: CGFloat, v: CGFloat){
        return (h: CGFloat(0.0), s: CGFloat(0.0), v: w)
    }
    
    
}

// Lab
extension CPColor {
    
    init( lab:(L: CGFloat, a: CGFloat, b: CGFloat ) ) {
        let channels = lab2rgb(lab:lab)
        self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:defaultAlpha)
    }
    
    var lab: (L: CGFloat, a: CGFloat, b: CGFloat ) {
        set {
            let channels = lab2rgb(lab:newValue)
            self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:rgba.a)
        }
        get {
            return rgb2lab(rgb:self.rgb)
        }
    }
    
    var labstr: String {
        let vals = self.lab
        let fL: String = String(format: "%f", vals.L*strm).round(3)
        let fa: String = String(format: "%f", vals.a*strm).round(3)
        let fb: String = String(format: "%f", vals.b*strm).round(3)
        return "L:"+fL+" a:"+fa+" b:"+fb
    }
    
    public func rgb2lab( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) -> (L: CGFloat, a: CGFloat, b: CGFloat) {
        //r,g,b = 0...1.0
        
        //L 0...1
        //a = -1.28...1.27
        //b = -1.28...1.27
        
        // d65
        
        if( rgb.r==0 && rgb.g==0 && rgb.b==0 )
        {
            return (L: 0.0, a: 0.0, b: 0.0)
        }
        
        let refX: CGFloat =  95.047
        let refY: CGFloat = 100.000
        let refZ: CGFloat = 108.883
        
        //matrix D65
        let ma: CGFloat = 0.412424
        let mb: CGFloat = 0.212656
        let mc: CGFloat = 0.0193324
        
        let md: CGFloat = 0.357579
        let me: CGFloat = 0.715158
        let mf: CGFloat = 0.119193
        
        let mg: CGFloat = 0.180464
        let mh: CGFloat = 0.0721856
        let mk: CGFloat =  0.950444
        
        var vR: CGFloat = rgb.r
        var vG: CGFloat = rgb.g
        var vB: CGFloat = rgb.b
        
        if( vR > 0.04045 )
        {
            vR = pow(((vR+0.055)/1.055), 2.4)
        }
        else
        {
            vR = vR/12.92
        }
        
        if( vG > 0.04045 )
        {
            vG = pow(((vG+0.055)/1.055), 2.4)
        }
        else
        {
            vG = vG/12.92
        }
        
        if( vB > 0.04045 )
        {
            vB = pow(((vB+0.055)/1.055), 2.4)
        }
        else
        {
            vB = vB/12.92
        }
        
        
        vR = vR*100.0
        vG = vG*100.0
        vB = vB*100.0
        
        let X: CGFloat = ma*vR+md*vG+mg*vB
        let Y: CGFloat = mb*vR+me*vG+mh*vB
        let Z: CGFloat = mc*vR+mf*vG+mk*vB
        
        var vX: CGFloat = X/refX
        var vY: CGFloat = Y/refY
        var vZ: CGFloat = Z/refZ
        
        if( vX > 0.008856 )
        {
            vX = pow(vX, 1.0/3.0 )
        }
        else
        {
            vX = (7.787*vX)+(16.0/116.0)
        }
        
        if( vY > 0.008856 )
        {
            vY = pow(vY, 1.0/3.0)
        }
        else
        {
            vY = (7.787*vY)+(16.0/116.0)
        }
        
        if( vZ > 0.008856 )
        {
            vZ = pow(vZ, 1.0/3.0)
        }
        else
        {
            vZ = (7.787*vZ)+(16.0/116.0)
        }
        
        return (L: ((116.0*vY)-16.0)/100.0,
                a: 5.0*(vX-vY),
                b: 2.0*(vY-vZ))
    }
    
    public func lab2rgb( lab:(L: CGFloat, a: CGFloat, b: CGFloat) ) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        //L 0...1
        //a = -1.28...1.27
        //b = -1.28...1.27
        
        //r,g,b = 0...1.0
        
        // d65
        
        let L: CGFloat = lab.L*100.0
        let a: CGFloat = lab.a*100.0
        let b: CGFloat = lab.b*100.0
        
        var vY: CGFloat = (L+16.0)/116.0
        var vX: CGFloat = a/500.0+vY
        var vZ: CGFloat = vY-b/200.0
        
        if( pow(vX, 3.0) > 0.008856 )
        {
            vX = pow(vX, 3.0)
        }
        else
        {
            vX = (vX-16.0/116.0)/7.787
        }
        
        if(pow(vY, 3.0) > 0.008856)
        {
            vY = pow(vY, 3.0)
        }
        else
        {
            vY = (vY-16.0/116.0)/7.787
        }
        
        if(pow(vZ, 3.0) > 0.008856)
        {
            vZ = pow(vZ, 3.0)
        }
        else
        {
            vZ = (vZ-16.0/116.0)/7.787
        }
        
        let refX: CGFloat =  95.047
        let refY: CGFloat = 100.000
        let refZ: CGFloat = 108.883
        
        vX = (refX*vX)/100.0
        vY = (refY*vY)/100.0
        vZ = (refZ*vZ)/100.0
        
        
        var vR: CGFloat = vX *  3.2406 + vY * -1.5372 + vZ * -0.4986
        var vG: CGFloat = vX * -0.9689 + vY *  1.8758 + vZ *  0.0415
        var vB: CGFloat = vX *  0.0557 + vY * -0.2040 + vZ *  1.0570
        
        if( vR > 0.0031308 )
        {
            vR = 1.055*(pow(vR,(1.0/2.4)))-0.055
        }
        else
        {
            vR = 12.92*vR
        }
        
        if( vG > 0.0031308 )
        {
            vG = 1.055*( pow(vG,(1.0/2.4)))-0.055
        }
        else
        {
            vG = 12.92*vG
        }
        
        if( vB > 0.0031308 )
        {
            vB = 1.055*( pow(vB,(1.0/2.4)))-0.055
        }
        else
        {
            vB = 12.92*vB
        }
        
        if(vR<0.0){
            vR = 0.0
        }
        if(vG<0.0){
            vG = 0.0
        }
        if(vB<0.0){
            vB = 0.0
        }
        
        if(vR>1.0){
            vR = 1.0
        }
        if(vG>1.0){
            vG = 1.0
        }
        if(vB>1.0){
            vB = 1.0
        }
        
        return (r: vR, g: vG, b: vB)
    }
}

// CMYK
extension CPColor {
    
    init( cmyk:(c: CGFloat, m: CGFloat, y: CGFloat, k:CGFloat) ) {
        let channels = cmyk2rgb(cmyk:cmyk)
        self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:defaultAlpha)
    }
    
    var cmyk: (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) {
        set {
            let channels = cmyk2rgb(cmyk:newValue)
            self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:rgba.a)
        }
        get {
            return rgb2cmyk(rgb:self.rgb)
        }
        
    }
    
    var cmykstr: String {
        let channels = self.cmyk
        
        let fc: String = String(format: "%.0f", channels.c*strm)
        let fm: String = String(format: "%.0f", channels.m*strm)
        let fy: String = String(format: "%.0f", channels.y*strm)
        let fk: String = String(format: "%.0f", channels.k*strm)
        return "C:"+fc+" M:"+fm+" Y:"+fy+" K:"+fk
    }
    
    public func cmyk2rgb( cmyk:(c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) ) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let w: CGFloat = cmyk.k-1.0
        let r: CGFloat = (1.0-cmyk.k+cmyk.c*w)
        let g: CGFloat = (1.0-cmyk.k+cmyk.m*w)
        let b: CGFloat = (1.0-cmyk.k+cmyk.y*w)
        
        return (r: r, g: g, b: b)
    }
    
    public func rgb2cmyk( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) -> (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) {
        
        let v1: CGFloat = 1.0-rgb.r
        let v2: CGFloat = 1.0-rgb.g
        let v3: CGFloat = 1.0-rgb.b
        
        var chrn: CGFloat = min(v1, v2)
        chrn = min(chrn, v3)
        let nChrn: CGFloat = 1.0-chrn
        
        if(nChrn==0.0){
            return (c: CGFloat(0.0), m: CGFloat(0.0), y: CGFloat(0.0), k: CGFloat(0.0) )
        }
        
        return (c: (v1-chrn)/nChrn, m: (v2-chrn)/nChrn, y: (v3-chrn)/nChrn, k: chrn )
    }
    
    public func cmyk2white(cmyk:(c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) )->CGFloat{
        let w: CGFloat = cmyk.k-1.0
        let r: CGFloat = (1.0-cmyk.k+cmyk.c*w)
        let g: CGFloat = (1.0-cmyk.k+cmyk.m*w)
        let b: CGFloat = (1.0-cmyk.k+cmyk.y*w)
        
        return rgb2white( rgb:(r:r, g:g, b:b) )
    }
    
    public func white2cmyk(w: CGFloat)->(c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat){
        let channels: (CGFloat, CGFloat, CGFloat) = white2rgb(w: w)
        return rgb2cmyk(rgb: channels)
    }
    
}

// HSL
extension CPColor {
    
    init( hsl:(h: CGFloat, s: CGFloat, l: CGFloat ) ) {
        let channels = hsl2rgb(hsl:hsl)
        self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:defaultAlpha)
    }
    
    var hsl: (h: CGFloat, s: CGFloat, l: CGFloat ) {
        set {
            let channels = hsl2rgb(hsl:newValue)
            self.rgba = (r: channels.r, g: channels.g, b: channels.b, a:rgba.a)
        }
        get {
            return rgb2hsl(rgb:self.rgb)
        }
    }
    
    var hslstr: String {
        let vals = self.hsl
        let fh: String = String(format: "%.0f", vals.h*strm)
        let fs: String = String(format: "%.0f", vals.s*strm)
        let fl: String = String(format: "%.0f", vals.l*strm)
        return "H:"+fh+" S:"+fs+" L:"+fl
    }
    
    public func hue2rgb( v1: CGFloat, v2: CGFloat, v3: CGFloat ) -> CGFloat {
        var vH = v3
        if(vH<0.0){
            vH += 1.0
        }
        if(vH>1.0){
            vH -= 1.0
        }
        if(6.0*vH < 1.0){
            return v1+(v2-v1)*6.0*vH
        }
        if(2.0*vH < 1.0){
            return v2
        }
        if(3.0*vH < 2.0){
            return v1+(v2-v1)*((2.0/3.0)-vH)*6.0
        }
        
        return v1
    }
    
    public func hsl2rgb( hsl:(h: CGFloat, s: CGFloat, l: CGFloat) ) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        
        if(hsl.l==1.0){
            return rgbWhite
        }
        
        if(hsl.l==0.0){
            return rgbBlack
        }
        
        var n: CGFloat = 0.0
        var k: CGFloat = 0.0
        if ( hsl.s == 0.0 ){
            return (r: hsl.l, g: hsl.l, b: hsl.l)
        }
        if(hsl.l<0.5){
            k = hsl.l*(1.0+hsl.s)
        }else {
            k = (hsl.l+hsl.s)-(hsl.s*hsl.l)
        }
        n = 2.0*hsl.l-k
        let r: CGFloat = hue2rgb(v1: n, v2: k, v3: hsl.h+(1.0/3.0) )
        let g: CGFloat = hue2rgb(v1: n, v2: k, v3: hsl.h+0.0 )
        let b: CGFloat = hue2rgb(v1: n, v2: k, v3: hsl.h-(1.0/3.0) )
        
        return (r: r, g: g, b: b)
    }
    
    public func rgb2hsl( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) -> (h: CGFloat, s: CGFloat, l: CGFloat) {
        let colorMax: CGFloat = max(max(rgb.r,rgb.g),rgb.b)
        let colorMin: CGFloat = min(min(rgb.r,rgb.g),rgb.b)
        let delta: CGFloat = colorMax-colorMin
        
        var H: CGFloat = 0.0
        var S: CGFloat
        var L: CGFloat
        
        L = (colorMax+colorMin)/2.0
        
        if(colorMax==colorMin){
            S = 0.0
        }else if (L<=0.5){
            S = delta/L/2.0
        }else{
            S = delta/(2.0-L*2.0)
        }
        
        if(colorMax==colorMin){
            H=0.0
        }else{
            let Thr: CGFloat = 0.0000001
            let colorMax1: CGFloat = max(max(rgb.r,rgb.g),rgb.b)
            let colorMin1: CGFloat = min(min(rgb.r,rgb.g),rgb.b)
            let delta1 = colorMax1-colorMin1
            if(delta1<Thr){
                H=0.0
            }
            if(rgb.r==colorMax1){
                H = (rgb.g-rgb.b)/delta1
            } else if(rgb.g == colorMax1){
                H = 2.0+(rgb.b-rgb.r)/delta1
            }else if(rgb.b==colorMax1){
                H=4.0+(rgb.r-rgb.g)/delta1
            }
            H=H*60.0
            if(H<0.0){
                H=H+360.0
            }
        }
        
        return (h: H/360.0, s: S, l: L)
    }
    
    public func hsl2white( hsl:(h: CGFloat, s: CGFloat, l: CGFloat) ) -> CGFloat {
        if(hsl.l==1.0){
            return 1.0
        }
        
        if(hsl.l==0.0){
            return 0.0
        }
        
        if (hsl.s==0.0){
            return hsl.l
        }
        
        var k: CGFloat = 0.0
        
        if(hsl.l<0.5){
            k = hsl.l*(1.0+hsl.s)
        }else {
            k = (hsl.l+hsl.s)-(hsl.s*hsl.l)
        }
        
        let n: CGFloat = 2.0*hsl.l-k
        let r: CGFloat = hue2rgb(v1:n, v2:k, v3:hsl.h+(1.0/3.0) )
        let g: CGFloat = hue2rgb(v1:n, v2:k, v3:hsl.h+0.0)
        let b: CGFloat = hue2rgb(v1:n, v2:k, v3:hsl.h-(1.0/3.0) )
        
        return rgb2white( rgb:(r:r, g:g, b:b) )
    }
    
    
}
