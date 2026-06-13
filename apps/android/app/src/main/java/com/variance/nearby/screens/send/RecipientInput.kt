package com.variance.nearby.screens.send

/**
 * Pure parsing + normalization of the recipient field. Accepts a raw `0x` address or a SuiNS name in
 * any of the forms `name`, `name.sui`, `sub.name`, `sub.name.sui` (a missing `.sui` is appended). No
 * network — fully unit-testable.
 */
sealed interface RecipientInput {
    data object Empty : RecipientInput

    /** A well-formed `0x…` address — usable directly, no resolution needed. */
    data class Address(val value: String) : RecipientInput

    /** A normalized SuiNS name (always `.sui`-terminated) to resolve to an address. */
    data class Name(val value: String) : RecipientInput

    /** Malformed — neither a valid address nor a valid name. */
    data object Invalid : RecipientInput

    companion object {
        fun parse(raw: String): RecipientInput {
            val trimmed = raw.trim().lowercase()
            if (trimmed.isEmpty()) return Empty

            if (trimmed.startsWith("0x")) {
                val hex = trimmed.substring(2)
                val valid = hex.isNotEmpty() && hex.length <= 64 &&
                    hex.all { it in '0'..'9' || it in 'a'..'f' }
                return if (valid) Address(trimmed) else Invalid
            }

            val name = if (trimmed.endsWith(".sui")) trimmed else "$trimmed.sui"
            return if (isValidName(name)) Name(name) else Invalid
        }

        /** A `.sui`-terminated name of one or more `[a-z0-9-]` labels. */
        private fun isValidName(name: String): Boolean {
            val labels = name.split(".")
            if (labels.size < 2 || labels.last() != "sui") return false
            val nameLabels = labels.dropLast(1)
            if (nameLabels.isEmpty()) return false
            return nameLabels.all { label ->
                label.isNotEmpty() && label.all { it in 'a'..'z' || it in '0'..'9' || it == '-' }
            }
        }
    }
}
