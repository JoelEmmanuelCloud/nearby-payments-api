package com.variance.nearby.screens.activity

import com.variance.nearby.core.AppConstants
import com.variance.nearby.leansui.api.GraphQLSuiProvider
import com.variance.nearby.leansui.api.SuiNetwork
import kotlinx.coroutines.future.await
import org.swift.swiftkit.core.SwiftArena
import java.util.Optional

/**
 * IO boundary for the on-chain activity feed. Forwards to the shared `getActivity` (fetch + fold +
 * format), scoped to the configured balance coin, and maps the bridged result into plain models.
 */
class ActivityService(
    network: SuiNetwork,
    private val swiftArena: SwiftArena,
    private val coinType: String = AppConstants.USD_SUI_COIN_TYPE,
) {
    private val provider: GraphQLSuiProvider = GraphQLSuiProvider.init(network, swiftArena)

    /** One page of the address's activity, newest first. Pass `cursor` = null for the first page. */
    suspend fun activity(address: String, cursor: String?): ActivityPage {
        val feed = provider
            .getActivity(address, coinType, Optional.ofNullable(cursor), DEFAULT_LIMIT, swiftArena)
            .await()
        return feed.toPage(swiftArena)
    }

    private companion object {
        // Page size is bounded by the GraphQL query cost; the package default is 25.
        const val DEFAULT_LIMIT = 25L
    }
}
