export const kDurationMsThreshold = 10

export function durationToMs(duration: number): number {
  return duration >= kDurationMsThreshold ? duration : duration * 1000
}

export function durationToSeconds(duration: number): number {
  return duration >= kDurationMsThreshold ? duration / 1000 : duration
}
