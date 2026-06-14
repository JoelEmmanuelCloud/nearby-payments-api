package com.variance.nearby.services.sui

import com.variance.nearby.leansui.api.GraphQLSuiProvider
import com.variance.nearby.leansui.api.SuiNetwork
import kotlinx.coroutines.future.await
import org.swift.swiftkit.core.SwiftArena

/** IO boundary for SuiNS forward resolution (`name.sui` → address). Wraps a GraphQL provider. */
class RecipientService(
    network: SuiNetwork,
    swiftArena: SwiftArena,
) {
    private val provider: GraphQLSuiProvider = GraphQLSuiProvider.init(network, swiftArena)

    /** The address a SuiNS name points at, or null if the name is unregistered. Uses the non-optional
     *  `…OrEmpty` variant — the optional-`String` bridge mis-marshals on Android ("" = unregistered). */
    suspend fun resolve(name: String): String? = provider.resolveNameServiceAddressOrEmpty(name).await().takeIf { it.isNotEmpty() }
}
