package utils

import "time"

func NowUnix() int64 {
	return time.Now().Unix()
}

func NowUnixMs() int64 {
	return time.Now().UnixMilli()
}

func UnixToTime(ts int64) time.Time {
	return time.Unix(ts, 0)
}

func InWindow(ts int64, skewSeconds int64) bool {
	now := NowUnix()
	diff := now - ts
	if diff < 0 {
		diff = -diff
	}
	return diff <= skewSeconds
}
