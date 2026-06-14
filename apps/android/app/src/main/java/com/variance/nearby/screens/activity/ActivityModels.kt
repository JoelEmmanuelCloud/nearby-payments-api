package com.variance.nearby.screens.activity

import com.variance.nearby.leansui.api.SuiActivity
import com.variance.nearby.leansui.api.SuiActivityCoinChange
import com.variance.nearby.leansui.api.SuiActivityDetail
import com.variance.nearby.leansui.api.SuiActivityDirection
import com.variance.nearby.leansui.api.SuiActivityFeed
import org.json.JSONArray
import org.json.JSONObject
import org.swift.swiftkit.core.SwiftArena

/** Plain, Compose-friendly mirrors of the bridged `SuiActivity*` value types. The bridged objects are
 *  mapped into these eagerly (within the arena) so Compose state never holds arena-bound natives. */

enum class ActivityDirection { SENT, RECEIVED }

data class ActivityCoinChange(
    val owner: String?,
    val coinType: String,
    val coinSymbol: String,
    val amount: String,
)

data class ActivityDetailUi(
    val digest: String,
    val sender: String?,
    val succeeded: Boolean,
    val executionError: String?,
    val timestampMillis: Long?,
    val coinChanges: List<ActivityCoinChange>,
)

data class ActivityRow(
    val digest: String,
    val direction: ActivityDirection,
    val amount: String,
    val coinSymbol: String,
    val counterparty: String?,
    val succeeded: Boolean,
    val timestampMillis: Long?,
    val details: ActivityDetailUi,
)

data class ActivityPage(
    val items: List<ActivityRow>,
    val nextCursor: String?,
    val hasMore: Boolean,
)

fun SuiActivityFeed.toPage(arena: SwiftArena): ActivityPage = ActivityPage(
    items = getItems(arena).map { it.toRow(arena) },
    nextCursor = nextCursor.orElse(null),
    hasMore = isHasMore,
)

private fun SuiActivity.toRow(arena: SwiftArena): ActivityRow = ActivityRow(
    digest = digest,
    direction = when (getDirection(arena).discriminator) {
        SuiActivityDirection.Discriminator.RECEIVED -> ActivityDirection.RECEIVED
        else -> ActivityDirection.SENT
    },
    amount = amount,
    coinSymbol = coinSymbol,
    counterparty = counterparty.orElse(null),
    succeeded = isSucceeded,
    timestampMillis = getTimestamp(arena).map { it.toInstant().toEpochMilli() }.orElse(null),
    details = getDetails(arena).toDetail(arena),
)

private fun SuiActivityDetail.toDetail(arena: SwiftArena): ActivityDetailUi = ActivityDetailUi(
    digest = digest,
    sender = sender.orElse(null),
    succeeded = isSucceeded,
    executionError = executionError.orElse(null),
    timestampMillis = getTimestamp(arena).map { it.toInstant().toEpochMilli() }.orElse(null),
    coinChanges = getCoinChanges(arena).map { it.toCoinChange() },
)

private fun SuiActivityCoinChange.toCoinChange(): ActivityCoinChange = ActivityCoinChange(
    owner = owner.orElse(null),
    coinType = coinType,
    coinSymbol = coinSymbol,
    amount = amount,
)

// JSON (de)serialization for the activity cache (manual via org.json, matching the profile cache).

fun List<ActivityRow>.toJsonString(): String = JSONArray().also { arr -> forEach { arr.put(it.toJson()) } }.toString()

fun activityRowsFromJson(text: String): List<ActivityRow> {
    val arr = JSONArray(text)
    return (0 until arr.length()).map { activityRowFromJson(arr.getJSONObject(it)) }
}

private fun ActivityRow.toJson(): JSONObject = JSONObject().apply {
    put("digest", digest)
    put("direction", direction.name)
    put("amount", amount)
    put("coinSymbol", coinSymbol)
    counterparty?.let { put("counterparty", it) }
    put("succeeded", succeeded)
    timestampMillis?.let { put("timestampMillis", it) }
    put("details", details.toJson())
}

private fun ActivityDetailUi.toJson(): JSONObject = JSONObject().apply {
    put("digest", digest)
    sender?.let { put("sender", it) }
    put("succeeded", succeeded)
    executionError?.let { put("executionError", it) }
    timestampMillis?.let { put("timestampMillis", it) }
    put("coinChanges", JSONArray().also { arr -> coinChanges.forEach { arr.put(it.toJson()) } })
}

private fun ActivityCoinChange.toJson(): JSONObject = JSONObject().apply {
    owner?.let { put("owner", it) }
    put("coinType", coinType)
    put("coinSymbol", coinSymbol)
    put("amount", amount)
}

private fun activityRowFromJson(json: JSONObject): ActivityRow = ActivityRow(
    digest = json.getString("digest"),
    direction = ActivityDirection.valueOf(json.getString("direction")),
    amount = json.getString("amount"),
    coinSymbol = json.getString("coinSymbol"),
    counterparty = json.optString("counterparty").ifEmpty { null },
    succeeded = json.getBoolean("succeeded"),
    timestampMillis = if (json.has("timestampMillis")) json.getLong("timestampMillis") else null,
    details = activityDetailFromJson(json.getJSONObject("details")),
)

private fun activityDetailFromJson(json: JSONObject): ActivityDetailUi = ActivityDetailUi(
    digest = json.getString("digest"),
    sender = json.optString("sender").ifEmpty { null },
    succeeded = json.getBoolean("succeeded"),
    executionError = json.optString("executionError").ifEmpty { null },
    timestampMillis = if (json.has("timestampMillis")) json.getLong("timestampMillis") else null,
    coinChanges = json.getJSONArray("coinChanges").let { arr ->
        (0 until arr.length()).map { coinChangeFromJson(arr.getJSONObject(it)) }
    },
)

private fun coinChangeFromJson(json: JSONObject): ActivityCoinChange = ActivityCoinChange(
    owner = json.optString("owner").ifEmpty { null },
    coinType = json.getString("coinType"),
    coinSymbol = json.getString("coinSymbol"),
    amount = json.getString("amount"),
)
