package com.variance.nearby

import com.variance.nearby.screens.send.AmountInput
import com.variance.nearby.screens.send.QuickSelect
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.math.BigDecimal

/** Pure tests for the send-amount keypad model and the predictive quick-select logic. */
class SendAmountTest {

    @Test
    fun replacesLeadingZeroAndAppends() {
        var input = AmountInput(maxFractionDigits = 6)
        assertEquals("0", input.display)
        input = input.appendDigit(0)
        assertEquals("0", input.text)
        input = input.appendDigit(5) // lone leading zero replaced, never "05"
        assertEquals("5", input.text)
        input = input.appendDigit(0)
        assertEquals("50", input.text)
    }

    @Test
    fun singleDecimalPointAndFractionCap() {
        var input = AmountInput(maxFractionDigits = 2)
        input = input.appendDecimal()
        assertEquals("0.", input.text)
        input = input.appendDecimal() // second decimal ignored
        assertEquals("0.", input.text)
        input = input.appendDigit(1).appendDigit(2)
        assertEquals("0.12", input.text)
        input = input.appendDigit(3) // exceeds 2 fraction digits → ignored
        assertEquals("0.12", input.text)
    }

    @Test
    fun validityAndValue() {
        var input = AmountInput(maxFractionDigits = 6)
        assertFalse(input.isValid)
        input = input.appendDigit(0)
        assertFalse(input.isValid) // "0" is not > 0
        input = input.appendDigit(5)
        assertTrue(input.isValid)
        assertEquals(0, BigDecimal(5).compareTo(input.decimalValue))
    }

    @Test
    fun setFormatsPlainly() {
        val input = AmountInput(maxFractionDigits = 6)
        assertEquals("5000", input.set(BigDecimal(5000)).text)
        assertEquals("55.5", input.set(BigDecimal("55.5")).text)
    }

    @Test
    fun quickSelectDefaultsWhenNothingTyped() {
        assertEquals(
            listOf(BigDecimal(10), BigDecimal(2000), BigDecimal(5000)),
            QuickSelect.suggestions(BigDecimal.ZERO),
        )
    }

    @Test
    fun quickSelectScalesTypedValue() {
        assertEquals(
            listOf(BigDecimal(50), BigDecimal(500), BigDecimal(5000)),
            QuickSelect.suggestions(BigDecimal(5)),
        )
    }
}
