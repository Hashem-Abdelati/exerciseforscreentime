//
//  GeometryHelpers.swift
//  exerciseforscreentime
//
//  Created by Hashem Abdelati on 2/2/26.
//

import CoreGraphics

func angle(a: CGPoint, b: CGPoint, c: CGPoint) -> Double {
    let ab = CGVector(dx: a.x - b.x, dy: a.y - b.y)
    let cb = CGVector(dx: c.x - b.x, dy: c.y - b.y)
    let dot = ab.dx * cb.dx + ab.dy * cb.dy
    let magAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy)
    let magCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy)
    guard magAB > 0, magCB > 0 else { return 0 }
    let cosVal = max(-1, min(1, dot / (magAB * magCB)))
    return acos(cosVal) * 180.0 / .pi
}
