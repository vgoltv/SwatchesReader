//
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
    
    var rgbHex: Int {
        let clr = self.rgba
        
        let r: CGFloat = min(max(clr.r, 0.0), 1.0)
        let g: CGFloat = min(max(clr.g, 0.0), 1.0)
        let b: CGFloat = min(max(clr.b, 0.0), 1.0)
        
        return (((Int)(round(r * 255.0))) << 16)
            | (((Int)(round(g * 255.0))) << 8)
            | (((Int)(round(b * 255.0))))
    }
    
    var hex: String {
        return String(format:"%06X", self.rgbHex)
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
    
    var hex: String {
        return asNative.hex
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
    public let rgbBlack: (r: CGFloat, g: CGFloat, b: CGFloat) = (r: 0.0, g: 0.0, b: 0.0)
    
    init(  ) {
        self.rgba = (r: CGFloat(0.0), g: CGFloat(0.0), b: CGFloat(0.0), a:defaultAlpha )
    }
    
    init( rgba:(r: CGFloat, g: CGFloat, b: CGFloat, a:CGFloat) ) {
        self.rgba = rgba
    }
    
    init( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) {
        self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:defaultAlpha )
    }
    
    init( white: CGFloat ) {
        let rgb = white2rgb(w: white)
        self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:defaultAlpha)
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
    
    var hex: String {
        let clr = self.rgba
        
        let r: CGFloat = min(max(clr.r, 0.0), 1.0)
        let g: CGFloat = min(max(clr.g, 0.0), 1.0)
        let b: CGFloat = min(max(clr.b, 0.0), 1.0)
        
        let rgb:Int =  (((Int)(round(r * 255.0))) << 16)
            | (((Int)(round(g * 255.0))) << 8)
            | (((Int)(round(b * 255.0))))
        
        return String(format:"%06X", rgb)
    }
    
    var rgbstr: String {
        let fr: String = String(format: "%.0f", self.rgba.r*strn)
        let fg: String = String(format: "%.0f", self.rgba.g*strn)
        let fb: String = String(format: "%.0f", self.rgba.b*strn)
        return "R:\(fr) G:\(fg) B:\(fb)"
    }
    
    var white: CGFloat {
        set {
            let rgb = white2rgb(w:newValue)
            self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:rgba.a)
        }
        get {
            return rgb2white(rgb:self.rgb)
        }
    }
    
    var whitestr: String {
        let w = String(format: "%f", self.white*strm)
        return "W:\(w.round(3))"
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
        let rgb = hsv2rgb(hsv:hsv)
        self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:defaultAlpha)
    }
    
    var hsv: (h: CGFloat, s: CGFloat, v: CGFloat ) {
        set {
            let rgb = hsv2rgb(hsv:newValue)
            self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:rgba.a)
        }
        get {
            return rgb2hsv(rgb:self.rgb)
        }
        
    }
    
    var hsvstr: String {
        let hsv = self.hsv
        let fh: String = String(format: "%.0f", hsv.h*strm)
        let fs: String = String(format: "%.0f", hsv.s*strm)
        let fv: String = String(format: "%.0f", hsv.v*strm)
        return "H:\(fh) S:\(fs) V:\(fv)"
    }
    
    public func hsv2rgb( hsv:(h: CGFloat, s: CGFloat, v: CGFloat) ) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        
        if( hsv.v == 0.0 ){
            return rgbBlack
        }
        
        if( hsv.v == 1.0 && hsv.s==0.0){
            return rgbWhite
        }
        
        var rem_1: CGFloat = 0.0
        var rem_2: CGFloat = 0.0
        var rem_3: CGFloat = 0.0
        var rem_4: CGFloat = 0.0
        
        if(hsv.h != 1.0){
            rem_4 = (hsv.h*360.0)/60.0
        }
        
        let rem_5: CGFloat = rem_4.rounded(.down)
        let rem_7: CGFloat = rem_4-rem_5
        let rem_8: CGFloat = (1.0-hsv.s)*hsv.v
        
        rem_3 = (1.0-hsv.s*rem_7)*hsv.v
        let rem_6: CGFloat = (1.0-hsv.s*(1.0-rem_7))*hsv.v
        
        switch (rem_5){
        case 0.0 :
            rem_1 = hsv.v
            rem_2 = rem_6
            rem_3 = rem_8
            break
        case 1.0 :
            rem_1 = rem_3
            rem_2 = hsv.v
            rem_3 = rem_8
            break
        case 2.0 :
            rem_1 = rem_8
            rem_2 = hsv.v
            rem_3 = rem_6
            break
        case 3.0 :
            rem_1 = rem_8
            rem_2 = rem_3
            rem_3 = hsv.v
            break
        case 4.0 :
            rem_1 = rem_6
            rem_2 = rem_8
            rem_3 = hsv.v
            break
        case 5.0 :
            rem_1 = hsv.v
            rem_2 = rem_8
            // rem_3 = rem_3
            break
        default :
            rem_1 = 0.0
            rem_2 = 0.0
            rem_3 = 0.0
        }
        
        return (r: rem_1, g: rem_2, b: rem_3)
    }
    
    public func rgb2hsv( rgb:(r: CGFloat, g: CGFloat, b: CGFloat) ) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        var rem0: CGFloat = 0.0
        
        let r_hsv: CGFloat = rgb.r
        let g_hsv: CGFloat = rgb.g
        let b_hsv: CGFloat = rgb.b
        
        let rem3: CGFloat = max( max(r_hsv, g_hsv), b_hsv)
        let rem4: CGFloat = min( min(r_hsv, g_hsv), b_hsv)
        var rem01: CGFloat = (rem3-rem4)/rem3
        let rem02: CGFloat = rem3
        
        if(rem01 == 0.0){
            rem0 = 0.0
        }else{
            let rem5: CGFloat = rem3-rem4
            if(rem5==0.0){
                rem0 = 0.0
                rem01 = 0.0
            }else{
                let red_m: CGFloat = (rem3-r_hsv)/rem5
                let gre_m: CGFloat = (rem3-g_hsv)/rem5
                let blu_m: CGFloat = (rem3-b_hsv)/rem5
                if (r_hsv==rem3&&g_hsv==rem4) {
                    rem0 = 5.0+blu_m
                } else {
                    if( (r_hsv == rem3) && (g_hsv != rem4) ) {
                        rem0 = 1.0-gre_m
                    }else{
                        if(g_hsv==rem3&&b_hsv==rem4){
                            rem0 = red_m+1.0
                        }else{
                            if(g_hsv == rem3 && b_hsv != rem4) {
                                rem0 = 3.0-blu_m
                            }else{
                                if (r_hsv == rem4){
                                    rem0 = 3.0+gre_m
                                } else {
                                    rem0 = 5.0-red_m
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
        
        
        return (h: rem0/360.0, s: rem01, v: rem02)
    }
    
    public func hsv2white( hsv:(h: CGFloat, s: CGFloat, v: CGFloat) )-> CGFloat{
        if(hsv.v==0.0){
            return 0.0
        }
        
        if(hsv.v==1.0 && hsv.s==0.0){
            return 1.0
        }
        
        var rem_1: CGFloat = 0.0
        var rem_2: CGFloat = 0.0
        var rem_3: CGFloat = 0.0
        var rem_4: CGFloat = 0.0
        
        if( hsv.h != 1.0 ){
            rem_4 = (hsv.h*360.0)/60.0
        }
        
        let rem_5: CGFloat = rem_4.rounded(.down)
        let rem_7: CGFloat = rem_4-rem_5
        let rem_8: CGFloat = (1.0-hsv.s)*hsv.v
        
        rem_3 = (1.0-hsv.s*rem_7)*hsv.v
        let rem_6: CGFloat = (1.0-hsv.s*(1.0-rem_7))*hsv.v
        
        switch (rem_5){
        case 0.0 :
            rem_1 = hsv.v
            rem_2 = rem_6
            rem_3 = rem_8
            break
        case 1.0 :
            rem_1 = rem_3
            rem_2 = hsv.v
            rem_3 = rem_8
            break
        case 2.0 :
            rem_1 = rem_8
            rem_2 = hsv.v
            rem_3 = rem_6
            break
        case 3.0 :
            rem_1 = rem_8
            rem_2 = rem_3
            rem_3 = hsv.v
            break
        case 4.0 :
            rem_1 = rem_6
            rem_2 = rem_8
            rem_3 = hsv.v
            break
        case 5.0 :
            rem_1 = hsv.v
            rem_2 = rem_8
            //rem_3 = rem_3
            break
        default :
            rem_1 = 0.0
            rem_2 = 0.0
            rem_3 = 0.0
        }
        
        return rgb2white( rgb:(r:rem_1, g:rem_2, b:rem_3) )
    }
    
    public func white2hsv(w: CGFloat)->(h: CGFloat, s: CGFloat, v: CGFloat){
        return (h: CGFloat(0.0), s: CGFloat(0.0), v: w)
    }
    
    
}

// Lab
extension CPColor {
    
    init( lab:(L: CGFloat, a: CGFloat, b: CGFloat ) ) {
        let rgb = lab2rgb(lab:lab)
        self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:defaultAlpha)
    }
    
    var lab: (L: CGFloat, a: CGFloat, b: CGFloat ) {
        set {
            let rgb = lab2rgb(lab:newValue)
            self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:rgba.a)
        }
        get {
            return rgb2lab(rgb:self.rgb)
        }
    }
    
    var labstr: String {
        let lab = self.lab
        let fL: String = String(format: "%f", lab.L*strm)
        let fa: String = String(format: "%f", lab.a*strm)
        let fb: String = String(format: "%f", lab.b*strm)
        return "L:\(fL.round(3)) a:\(fa.round(3)) b:\(fb.round(3))"
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
        
        let ref_X: CGFloat =  95.047
        let ref_Y: CGFloat = 100.000
        let ref_Z: CGFloat = 108.883
        
        //matrix D65
        let ma: CGFloat = 0.412424; let mb: CGFloat = 0.212656; let mc: CGFloat = 0.0193324;
        let md: CGFloat = 0.357579; let me: CGFloat = 0.715158; let mf: CGFloat = 0.119193;
        let mg: CGFloat = 0.180464; let mh: CGFloat = 0.0721856; let mk: CGFloat =  0.950444;
        
        
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
            vG = pow(((vG+0.055)/1.055), 2.4);
        }
        else
        {
            vG = vG/12.92
        }
        
        if( vB > 0.04045 )
        {
            vB = pow(((vB+0.055)/1.055), 2.4);
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
        
        var vX: CGFloat = X/ref_X
        var vY: CGFloat = Y/ref_Y
        var vZ: CGFloat = Z/ref_Z
        
        if( vX > 0.008856 )
        {
            vX = pow(vX, 1.0/3.0 );
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
            vZ = pow(vZ, 1.0/3.0);
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
            vX = pow(vX, 3.0);
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
        
        let ref_X: CGFloat =  95.047
        let ref_Y: CGFloat = 100.000
        let ref_Z: CGFloat = 108.883
        
        vX = (ref_X*vX)/100.0
        vY = (ref_Y*vY)/100.0
        vZ = (ref_Z*vZ)/100.0
        
        
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
        let rgb = cmyk2rgb(cmyk:cmyk)
        self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:defaultAlpha)
    }
    
    var cmyk: (c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat) {
        set {
            let rgb = cmyk2rgb(cmyk:newValue)
            self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:rgba.a)
        }
        get {
            return rgb2cmyk(rgb:self.rgb)
        }
        
    }
    
    var cmykstr: String {
        let cmyk = self.cmyk
        
        let fc: String = String(format: "%.0f", cmyk.c*strm)
        let fm: String = String(format: "%.0f", cmyk.m*strm)
        let fy: String = String(format: "%.0f", cmyk.y*strm)
        let fk: String = String(format: "%.0f", cmyk.k*strm)
        return "C:\(fc) M:\(fm) Y:\(fy) K:\(fk)"
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
        
        return rgb2white( rgb:(r:r, g:g, b:b) );
    }
    
    public func white2cmyk(w: CGFloat)->(c: CGFloat, m: CGFloat, y: CGFloat, k: CGFloat){
        let rgb: (CGFloat, CGFloat, CGFloat) = white2rgb(w: w)
        return rgb2cmyk(rgb: rgb)
    }
    
}

// HSL
extension CPColor {
    
    init( hsl:(h: CGFloat, s: CGFloat, l: CGFloat ) ) {
        let rgb = hsl2rgb(hsl:hsl)
        self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:defaultAlpha)
    }
    
    var hsl: (h: CGFloat, s: CGFloat, l: CGFloat ) {
        set {
            let rgb = hsl2rgb(hsl:newValue)
            self.rgba = (r: rgb.r, g: rgb.g, b: rgb.b, a:rgba.a)
        }
        get {
            return rgb2hsl(rgb:self.rgb)
        }
    }
    
    var hslstr: String {
        let hsl = self.hsl
        let fh: String = String(format: "%.0f", hsl.h*strm)
        let fs: String = String(format: "%.0f", hsl.s*strm)
        let fl: String = String(format: "%.0f", hsl.l*strm)
        return "H:\(fh) S:\(fs) L:\(fl)"
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
            S = 0.0;
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
