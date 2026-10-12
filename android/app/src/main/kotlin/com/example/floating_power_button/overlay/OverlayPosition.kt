package com.example.floating_power_button.overlay

/**
 * Immutable top-left position of the floating button window, in pixels.
 */
internal data class OverlayPosition(val x: Int, val y: Int)

/**
 * Pure geometry rules for the floating button window.
 *
 * This object intentionally has no Android dependencies so the clamping rules
 * (restore, rotation, display-area changes) can be covered by JVM unit tests.
 */
internal object OverlayPositionCalculator {

    /**
     * Keeps the button fully inside [containerWidth] x [containerHeight].
     *
     * If the container is smaller than the button the position collapses to 0,0
     * instead of producing a negative bound.
     */
    fun clamp(
        x: Int,
        y: Int,
        containerWidth: Int,
        containerHeight: Int,
        viewWidth: Int,
        viewHeight: Int,
    ): OverlayPosition {
        val maxX = (containerWidth - viewWidth).coerceAtLeast(0)
        val maxY = (containerHeight - viewHeight).coerceAtLeast(0)
        return OverlayPosition(x.coerceIn(0, maxX), y.coerceIn(0, maxY))
    }

    /**
     * Position used the first time the button is shown: right edge, vertically
     * centered, [margin] pixels away from both edges (margin is ignored when it
     * does not fit).
     */
    fun defaultPosition(
        containerWidth: Int,
        containerHeight: Int,
        viewWidth: Int,
        viewHeight: Int,
        margin: Int,
    ): OverlayPosition {
        val x = containerWidth - viewWidth - margin
        val y = (containerHeight - viewHeight) / 2
        return clamp(x, y, containerWidth, containerHeight, viewWidth, viewHeight)
    }
}