// Time formatting matching formatNoLeadingZeroHours in GroundingScreenView.swift

export function formatNoLeadingZeroHours(seconds: number): string {
  if (!Number.isFinite(seconds) || seconds <= 0) {
    return '0:00';
  }
  const total = Math.max(0, Math.ceil(seconds));
  const hrs = Math.floor(total / 3600);
  const mins = Math.floor((total % 3600) / 60);
  const secs = total % 60;

  const pad = (n: number) => (n < 10 ? `0${n}` : `${n}`);

  if (hrs > 0) {
    return `${hrs}:${pad(mins)}:${pad(secs)}`;
  } else {
    return `${mins}:${pad(secs)}`;
  }
}

// Progressive timer steps from 0 to 4 hours (14400s)
// - 0s: Stop / Off
// - 1m to 30m: 1-minute steps (granular precision for quick sessions)
// - 35m to 60m: 5-minute steps
// - 1h 15m to 4h: 15-minute steps
export const TIMER_STEPS: number[] = (() => {
  const steps: number[] = [0];

  // 1 to 30 minutes in 1-minute increments
  for (let m = 1; m <= 30; m++) {
    steps.push(m * 60);
  }

  // 35 to 60 minutes in 5-minute increments
  for (let m = 35; m <= 60; m += 5) {
    steps.push(m * 60);
  }

  // 1h 15m (75 min) to 4h (240 min) in 15-minute increments
  for (let m = 75; m <= 240; m += 15) {
    steps.push(m * 60);
  }

  return steps;
})();

export function findClosestStepIndex(seconds: number): number {
  if (!Number.isFinite(seconds) || seconds <= 0) {
    return 0;
  }
  let closestIndex = 0;
  let minDiff = Infinity;
  for (let i = 0; i < TIMER_STEPS.length; i++) {
    const diff = Math.abs(TIMER_STEPS[i] - seconds);
    if (diff < minDiff) {
      minDiff = diff;
      closestIndex = i;
    }
  }
  return closestIndex;
}

