package com.variance.nearby.screens.activity

import android.content.ClipData
import android.text.format.DateUtils
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.ClipEntry
import androidx.compose.ui.platform.LocalClipboard
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.variance.nearby.R
import com.variance.nearby.core.AppConstants
import com.variance.nearby.ui.Card
import com.variance.nearby.ui.MutedText
import com.variance.nearby.ui.Skeleton
import com.variance.nearby.ui.theme.Green40
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.milliseconds

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ActivityScreen(
    viewModel: ActivityViewModel,
    currentAddress: String?,
    modifier: Modifier = Modifier,
) {
    var selected by remember { mutableStateOf<ActivityRow?>(null) }

    LaunchedEffect(Unit) { viewModel.load() }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = { Text(text = "Activity", fontWeight = FontWeight.Bold, fontSize = 20.sp) },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background,
                ),
            )
        },
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(innerPadding),
        ) {
            when (viewModel.phase) {
                ActivityViewModel.Phase.LOADING ->
                    ActivitySkeleton()
                ActivityViewModel.Phase.EMPTY ->
                    Placeholder(title = "No activity yet", subtitle = "Your transfers will show up here.")
                ActivityViewModel.Phase.ERROR ->
                    ErrorState()
                ActivityViewModel.Phase.CONTENT ->
                    ActivityList(viewModel = viewModel, onSelect = { selected = it })
            }
        }
    }

    selected?.let { row ->
        ModalBottomSheet(
            onDismissRequest = { selected = null },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        ) {
            ActivityDetailSheet(row = row, currentAddress = currentAddress)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ActivityList(
    viewModel: ActivityViewModel,
    onSelect: (ActivityRow) -> Unit,
) {
    val listState = rememberLazyListState()

    // Infinite scroll: load more once the last item scrolls into view.
    LaunchedEffect(listState, viewModel.items.size) {
        snapshotFlow {
            val info = listState.layoutInfo
            val last = info.visibleItemsInfo.lastOrNull()?.index ?: -1
            info.totalItemsCount > 0 && last >= info.totalItemsCount - 1
        }.distinctUntilChanged().collect { atEnd -> if (atEnd) viewModel.loadMore() }
    }

    PullToRefreshBox(
        isRefreshing = viewModel.isRefreshing,
        onRefresh = { viewModel.load() },
        modifier = Modifier.fillMaxSize(),
    ) {
        LazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp),
        ) {
            items(viewModel.items, key = { it.digest }) { row ->
                ActivityRowItem(row = row, onClick = { onSelect(row) })
            }
            if (viewModel.isLoadingMore) {
                item {
                    Box(modifier = Modifier.fillMaxWidth().padding(16.dp), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(modifier = Modifier.size(24.dp), strokeWidth = 2.dp)
                    }
                }
            }
        }
    }
}

@Composable
private fun ActivitySkeleton() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        repeat(8) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Skeleton(modifier = Modifier.size(40.dp), shape = CircleShape)
                Spacer(modifier = Modifier.width(12.dp))
                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Skeleton(modifier = Modifier.width(80.dp).height(14.dp))
                    Skeleton(modifier = Modifier.width(120.dp).height(10.dp))
                }
                Column(
                    horizontalAlignment = Alignment.End,
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Skeleton(modifier = Modifier.width(70.dp).height(14.dp))
                    Skeleton(modifier = Modifier.width(40.dp).height(10.dp))
                }
            }
        }
    }
}

@Composable
private fun ErrorState() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Icon(
            painter = painterResource(id = R.drawable.warning),
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.size(56.dp),
        )
        Text(
            text = "Error encountered during fetch.",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
        )
    }
}

@Composable
private fun ActivityRowItem(row: ActivityRow, onClick: () -> Unit) {
    val received = row.direction == ActivityDirection.RECEIVED
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.surfaceVariant),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(
                    id = if (received) R.drawable.arrow_downward else R.drawable.arrow_outward,
                ),
                contentDescription = null,
                tint = if (received) Green40 else MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.size(18.dp),
            )
        }

        Spacer(modifier = Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = if (received) "Received" else "Sent",
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Medium,
            )
            row.counterparty?.let { party ->
                Text(
                    text = "${if (received) "From" else "To"} ${shortSuiAddress(party)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }

        Column(horizontalAlignment = Alignment.End) {
            Text(
                text = "${if (received) "+" else "-"}${row.amount} ${row.coinSymbol}",
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.SemiBold,
                color = if (received) Green40 else MaterialTheme.colorScheme.onSurface,
            )
            if (!row.succeeded) {
                Text(
                    text = "Failed",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.error,
                )
            } else {
                row.timestampMillis?.let {
                    Text(
                        text = relativeTime(it),
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
    }
}

@Composable
private fun ActivityDetailSheet(row: ActivityRow, currentAddress: String?) {
    val clipboard = LocalClipboard.current
    val uriHandler = LocalUriHandler.current
    val scope = rememberCoroutineScope()

    var digestCopied by remember { mutableStateOf(false) }
    LaunchedEffect(digestCopied) {
        if (digestCopied) {
            delay(1500.milliseconds)
            digestCopied = false
        }
    }

    val received = row.direction == ActivityDirection.RECEIVED

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(start = 24.dp, end = 24.dp, bottom = 32.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(
                text = if (received) "Received" else "Sent",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                text = "${if (received) "+" else "-"}${row.amount} ${row.coinSymbol}",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.SemiBold,
                color = if (received) Green40 else MaterialTheme.colorScheme.onSurface,
            )
        }

        Card(modifier = Modifier.fillMaxWidth()) {
            DetailRow("Status", if (row.succeeded) "Success" else "Failed")
            row.details.sender?.let { DetailRow("Sender", suiPartyLabel(it, currentAddress), mono = true) }
            row.counterparty?.let {
                DetailRow(if (received) "From" else "To", suiPartyLabel(it, currentAddress), mono = true)
            }
            row.timestampMillis?.let { DetailRow("When", absoluteTime(it)) }
            // Tap to copy the full digest; the value briefly flickers to "Copied" then reverts.
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable {
                        scope.launch {
                            clipboard.setClipEntry(
                                ClipEntry(ClipData.newPlainText("Digest", row.digest)),
                            )
                        }
                        digestCopied = true
                    },
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = "Digest",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = if (digestCopied) "Copied" else shortSuiAddress(row.digest, leading = 8, trailing = 6),
                    style = MaterialTheme.typography.bodyMedium.copy(
                        fontFamily = if (digestCopied) FontFamily.Default else FontFamily.Monospace,
                    ),
                    color = if (digestCopied) Green40 else MaterialTheme.colorScheme.onSurface,
                )
            }
        }

        if (row.details.coinChanges.isNotEmpty()) {
            Card(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Balance changes",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                )
                row.details.coinChanges.forEach { change ->
                    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = suiPartyLabel(change.owner, currentAddress),
                            style = MaterialTheme.typography.bodySmall.copy(fontFamily = FontFamily.Monospace),
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Spacer(modifier = Modifier.weight(1f))
                        Text(
                            text = "${change.amount} ${change.coinSymbol}",
                            style = MaterialTheme.typography.bodySmall,
                            fontWeight = FontWeight.Medium,
                        )
                    }
                }
            }
        }

        TextButton(
            onClick = { uriHandler.openUri(suiExplorerUrl(row.digest, AppConstants.SUI_NETWORK)) },
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text("View on Suiscan", fontWeight = FontWeight.Medium)
            Spacer(modifier = Modifier.width(8.dp))
            Icon(
                painter = painterResource(id = R.drawable.open_in_new),
                contentDescription = null,
                modifier = Modifier.size(18.dp),
            )
        }
    }
}

@Composable
private fun DetailRow(label: String, value: String, mono: Boolean = false) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        Spacer(modifier = Modifier.weight(1f))
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium.copy(
                fontFamily = if (mono) FontFamily.Monospace else FontFamily.Default,
            ),
        )
    }
}

@Composable
private fun Placeholder(title: String, subtitle: String) {
    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(text = title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
        MutedText(value = subtitle)
    }
}

private fun relativeTime(millis: Long): String = DateUtils.getRelativeTimeSpanString(millis).toString()

private fun absoluteTime(millis: Long): String = java.text.DateFormat.getDateTimeInstance(
    java.text.DateFormat.MEDIUM,
    java.text.DateFormat.SHORT,
).format(java.util.Date(millis))
