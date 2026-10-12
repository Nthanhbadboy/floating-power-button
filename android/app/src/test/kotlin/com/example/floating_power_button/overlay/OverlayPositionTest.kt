package com.example.floating_power_button.overlay

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * JVM unit tests for the overlay position rules (Milestone 1).
 *
 * These cover the "position restored after service restart and after rotation"
 * rule: any stored/restore position must be clamped back into the visible area.
 */
class OverlayPositionTest {

    @Test
    fun `keeps a valid position untouched`() {
        val result =
            OverlayPositionCalculator.clamp(
                x = 100,
                y = 200,
                containerWidth = 1080,
                containerHeight = 1920,
                viewWidth = 160,
                viewHeight = 160,
            )

        assertEquals(OverlayPosition(100, 200), result)
    }

    @Test
    fun `clamps position stored on a larger display`() {
        val result =
            OverlayPositionCalculator.clamp(
                x = 1000,
                y = 1800,
                containerWidth = 1080,
                containerHeight = 1920,
                viewWidth = 160,
                viewHeight = 160,
            )

        assertEquals(OverlayPosition(920, 1760), result)
    }

    @Test
    fun `clamps negative position to the top left corner`() {
        val result =
            OverlayPositionCalculator.clamp(
                x = -50,
                y = -10,
                containerWidth = 1080,
                containerHeight = 1920,
                viewWidth = 160,
                viewHeight = 160,
            )

        assertEquals(OverlayPosition(0, 0), result)
    }

    @Test
    fun `collapses to origin when the container is smaller than the button`() {
        val result =
            OverlayPositionCalculator.clamp(
                x = 40,
                y = 40,
                containerWidth = 120,
                containerHeight = 120,
                viewWidth = 160,
                viewHeight = 160,
            )

        assertEquals(OverlayPosition(0, 0), result)
    }

    @Test
    fun `default position sits on the right edge and is vertically centered`() {
        val result =
            OverlayPositionCalculator.defaultPosition(
                containerWidth = 1080,
                containerHeight = 1920,
                viewWidth = 160,
                viewHeight = 160,
                margin = 16,
            )

        assertEquals(OverlayPosition(904, 880), result)
    }

    @Test
    fun `default position stays inside a small display`() {
        val result =
            OverlayPositionCalculator.defaultPosition(
                containerWidth = 200,
                containerHeight = 200,
                viewWidth = 160,
                viewHeight = 160,
                margin = 64,
            )

        assertEquals(OverlayPosition(0, 20), result)
    }

    @Test
    fun `rotation from landscape to portrait pulls the button back on screen`() {
        // Position saved in landscape (x is far right for the wide screen).
        val landscape = OverlayPositionCalculator.clamp(1900, 500, 2400, 1080, 160, 160)

        // Same stored coordinates on a portrait display of the same device.
        val portrait =
            OverlayPositionCalculator.clamp(landscape.x, landscape.y, 1080, 2400, 160, 160)

        assertEquals(1900, landscape.x)
        assertEquals(920, portrait.x)
        assertEquals(500, portrait.y)
    }
}