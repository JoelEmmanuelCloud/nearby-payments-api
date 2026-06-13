package com.variance.nearby

import com.variance.nearby.screens.send.RecipientInput
import org.junit.Assert.assertEquals
import org.junit.Test

/** Pure tests for recipient parsing/normalization (addresses + SuiNS names). */
class RecipientInputTest {

    private val address = "0x" + "a".repeat(64)

    @Test
    fun blankIsEmpty() {
        assertEquals(RecipientInput.Empty, RecipientInput.parse("   "))
    }

    @Test
    fun wellFormedAddress() {
        assertEquals(RecipientInput.Address(address), RecipientInput.parse(address))
        assertEquals(RecipientInput.Address("0xabc"), RecipientInput.parse("0xABC")) // lowercased
    }

    @Test
    fun malformedAddress() {
        assertEquals(RecipientInput.Invalid, RecipientInput.parse("0xZZ")) // non-hex
        assertEquals(RecipientInput.Invalid, RecipientInput.parse("0x" + "a".repeat(65))) // too long
    }

    @Test
    fun bareNameGetsSuiSuffix() {
        assertEquals(RecipientInput.Name("alice.sui"), RecipientInput.parse("alice"))
        assertEquals(RecipientInput.Name("alice.nearby.sui"), RecipientInput.parse("alice.nearby"))
    }

    @Test
    fun suiSuffixKept() {
        assertEquals(RecipientInput.Name("alice.sui"), RecipientInput.parse("alice.sui"))
        assertEquals(RecipientInput.Name("alice.sui"), RecipientInput.parse(" ALICE.SUI "))
    }

    @Test
    fun malformedName() {
        assertEquals(RecipientInput.Invalid, RecipientInput.parse("ali ce")) // space in label
        assertEquals(RecipientInput.Invalid, RecipientInput.parse("..sui")) // empty label
    }
}
