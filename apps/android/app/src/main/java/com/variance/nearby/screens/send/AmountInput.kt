package com.variance.nearby.screens.send

import java.math.BigDecimal

/**
 * The numeric-keypad input model for the send amount. Immutable value type — keypad taps return a new
 * instance and the screen renders [display] — so the entry rules (single decimal point, bounded
 * fraction length, no leading-zero noise) are unit-testable without any UI.
 */
data class AmountInput(
    val maxFractionDigits: Int,
    val text: String = "",
    /** Upper bound on the entered amount; digits that would exceed it are ignored. */
    val maxValue: BigDecimal = BigDecimal(1_000_000_000),
) {
    /** What the big number shows — "0" while empty so the field is never blank. */
    val display: String get() = text.ifEmpty { "0" }

    val decimalValue: BigDecimal get() = text.toBigDecimalOrNull() ?: BigDecimal.ZERO

    /** A strictly-positive amount has been entered (gates the "Next" action). */
    val isValid: Boolean get() = decimalValue > BigDecimal.ZERO

    fun appendDigit(digit: Int): AmountInput {
        if (digit !in 0..9 || fractionIsFull) return this
        // Replace a lone leading "0" so we never produce "07" or "00".
        val candidate = if (text == "0") digit.toString() else text + digit.toString()
        val value = candidate.toBigDecimalOrNull()
        if (value != null && value > maxValue) return this
        return copy(text = candidate)
    }

    fun appendDecimal(): AmountInput {
        if (text.contains(".")) return this
        return copy(text = if (text.isEmpty()) "0." else "$text.")
    }

    fun backspace(): AmountInput = if (text.isEmpty()) this else copy(text = text.dropLast(1))

    /** Replaces the entry with [value] (used by the quick-select chips), as a plain "."-separated
     *  string so it round-trips through [decimalValue] and [display] unchanged. */
    fun set(value: BigDecimal): AmountInput = copy(text = value.stripTrailingZeros().toPlainString())

    /** Whether the fraction already holds [maxFractionDigits] digits (further digits are ignored). */
    private val fractionIsFull: Boolean
        get() {
            val dot = text.indexOf('.')
            return dot >= 0 && text.length - dot - 1 >= maxFractionDigits
        }
}

/** A key on the send keypad. */
sealed interface KeypadKey {
    data class Digit(val value: Int) : KeypadKey
    data object Decimal : KeypadKey
    data object Backspace : KeypadKey
}
