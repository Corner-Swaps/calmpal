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
