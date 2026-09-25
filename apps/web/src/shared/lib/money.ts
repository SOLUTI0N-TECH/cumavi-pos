/**
 * Bolivianos in the same format as the POS app: `Bs 1.229,00`.
 * Written by hand because `Intl` skips the thousands separator below 10.000
 * in some Spanish locales.
 */
export function formatMoney(amount: number): string {
  const [integer, decimals] = Math.abs(amount).toFixed(2).split('.');
  const grouped = integer.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  return `${amount < 0 ? '−' : ''}Bs ${grouped},${decimals}`;
}
