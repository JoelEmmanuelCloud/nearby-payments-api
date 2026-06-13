package com.variance.nearby

import com.variance.nearby.screens.profile.LeafNameInput
import org.junit.Assert.assertEquals
import org.junit.Test

/** Pure tests for Nearby leaf-name validation (no auto-stripping; a space is invalid). */
class LeafNameInputTest {

    @Test
    fun blankIsEmpty() {
        assertEquals(LeafNameInput.Empty, LeafNameInput.parse("   "))
    }

    @Test
    fun validLabelNormalizes() {
        assertEquals(LeafNameInput.Valid("alice"), LeafNameInput.parse("alice"))
        assertEquals(LeafNameInput.Valid("alice"), LeafNameInput.parse("  ALICE  "))
        assertEquals(LeafNameInput.Valid("a-1"), LeafNameInput.parse("a-1"))
    }

    @Test
    fun spaceOrSymbolIsInvalid() {
        assertEquals(LeafNameInput.Invalid, LeafNameInput.parse("ali ce"))
        assertEquals(LeafNameInput.Invalid, LeafNameInput.parse("alice!"))
        assertEquals(LeafNameInput.Invalid, LeafNameInput.parse("ali.ce"))
    }
}
