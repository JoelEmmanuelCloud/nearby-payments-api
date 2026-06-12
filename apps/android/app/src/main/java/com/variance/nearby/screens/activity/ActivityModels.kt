package com.variance.nearby.screens.activity

import com.variance.nearby.leansui.api.SuiActivity
import com.variance.nearby.leansui.api.SuiActivityCoinChange
import com.variance.nearby.leansui.api.SuiActivityDetail
import com.variance.nearby.leansui.api.SuiActivityDirection
import com.variance.nearby.leansui.api.SuiActivityFeed
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
