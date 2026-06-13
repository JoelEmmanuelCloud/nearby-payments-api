package com.variance.nearby.screens.send

import java.math.BigDecimal

/**
 * Pure logic for the predictive quick-select chips: as the user types, three scaled amounts are
 * suggested so a round figure is one tap away. No UI, fully unit-testable.
 */
object QuickSelect {
    /** Starter chips shown before anything positive is typed. */
    val defaults: List<BigDecimal> = listOf(BigDecimal(10), BigDecimal(2000), BigDecimal(5000))

    /** Three quick-pick amounts for the typed [value]: ×10, ×100, ×1000 (so "5" → 50 / 500 / 5000),
     *  or the defaults when nothing positive is entered. */
    fun suggestions(value: BigDecimal): List<BigDecimal> {
        if (value <= BigDecimal.ZERO) return defaults
        return listOf(value * BigDecimal(10), value * BigDecimal(100), value * BigDecimal(1000))
    }
}
