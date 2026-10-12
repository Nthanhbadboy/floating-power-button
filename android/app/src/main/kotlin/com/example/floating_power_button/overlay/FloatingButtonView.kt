package com.example.floating_power_button.overlay

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import com.example.floating_power_button.R
import kotlin.math.hypot
import kotlin.math.roundToInt

/**
 * The floating button view added to the overlay window.
 *
 * Gesture rules (Milestone 1):
 *  - a touch that stays inside the system touch slop is a *tap*;
 *  - a touch that travels further than the slop becomes a *drag* and every move
 *    reports the delta to the owner, which updates the window LayoutParams.
 *
 * The view is deliberately dumb: it draws a power glyph and reports gestures, it
 * does not know about WindowManager, services or permissions.
 */
internal class FloatingButtonView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : View(context, attrs) {

    /** Invoked on a tap (no drag). Milestone 2 binds the selected function here. */
    var onTap: (() -> Unit)? = null

    /** Invoked while dragging with the pixel delta since the previous move event. */
    var onMove: ((dx: Int, dy: Int) -> Unit)? = null

    /** Invoked once when a drag ends, so the position can be persisted. */
    var onMoveFinished: (() -> Unit)? = null

    private val touchSlop = ViewConfiguration.get(context).scaledTouchSlop.toFloat()

    private var downRawX = 0f
    private var downRawY = 0f
    private var lastRawX = 0f
    private var lastRawY = 0f
    private var dragging = false

    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#1F6FEB")
    }
    private val glyphPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
    }

    init {
        isClickable = true
        isFocusable = true
        contentDescription = context.getString(R.string.overlay_button_description)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        val stroke = w * 0.085f
        glyphPaint.strokeWidth = stroke
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val w = width.toFloat()
        val h = height.toFloat()
        val centerX = w / 2f
        val centerY = h / 2f
        val radius = w * 0.5f
        canvas.drawCircle(centerX, centerY, radius, fillPaint)

        // Power glyph: an open circle plus the stem, drawn without any drawable asset.
        val glyphRadius = radius * 0.42f
        val gapHalfWidth = glyphRadius * 0.45f
        val stemTop = centerY - radius * 0.62f
        canvas.drawLine(centerX, stemTop, centerX, centerY - glyphRadius * 0.15f, glyphPaint)
        val arcBounds = RectF(
            centerX - glyphRadius,
            centerY - glyphRadius,
            centerX + glyphRadius,
            centerY + glyphRadius,
        )
        canvas.drawArc(arcBounds, gapHalfWidth + 30f, 300f, false, glyphPaint)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                downRawX = event.rawX
                downRawY = event.rawY
                lastRawX = downRawX
                lastRawY = downRawY
                dragging = false
                return true
            }

            MotionEvent.ACTION_MOVE -> {
                if (!dragging &&
                    hypot(event.rawX - downRawX, event.rawY - downRawY) > touchSlop
                ) {
                    dragging = true
                }
                if (dragging) {
                    dispatchMove(event.rawX, event.rawY)
                }
                return true
            }

            MotionEvent.ACTION_UP -> {
                if (dragging) {
                    dispatchMove(event.rawX, event.rawY)
                    onMoveFinished?.invoke()
                } else {
                    performClick()
                }
                dragging = false
                return true
            }

            MotionEvent.ACTION_CANCEL -> {
                if (dragging) {
                    onMoveFinished?.invoke()
                }
                dragging = false
                return true
            }
        }
        return super.onTouchEvent(event)
    }

    override fun performClick(): Boolean {
        super.performClick()
        onTap?.invoke()
        return true
    }

    private fun dispatchMove(rawX: Float, rawY: Float) {
        val dx = (rawX - lastRawX).roundToInt()
        val dy = (rawY - lastRawY).roundToInt()
        lastRawX = rawX
        lastRawY = rawY
        if (dx != 0 || dy != 0) {
            onMove?.invoke(dx, dy)
        }
    }
}