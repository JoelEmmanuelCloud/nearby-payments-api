package com.variance.nearby.screens.profile

/**
 * Pure validation of a Nearby leaf-name entry. A label is one or more `[a-z0-9-]` characters; a space
 * (or any other character) makes it invalid rather than being silently stripped. No network.
 */
sealed interface LeafNameInput {
    data object Empty : LeafNameInput

    /** A normalized (trimmed, lowercased) valid label. */
    data class Valid(val value: String) : LeafNameInput

    data object Invalid : LeafNameInput

    companion object {
        fun parse(raw: String): LeafNameInput {
            val trimmed = raw.trim()
            if (trimmed.isEmpty()) return Empty
            val lower = trimmed.lowercase()
            val valid = lower.all { it in 'a'..'z' || it in '0'..'9' || it == '-' }
            return if (valid) Valid(lower) else Invalid
        }
    }
}
