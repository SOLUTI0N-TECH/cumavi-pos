/**
 * Bolivian mobile numbers, same rules as the POS app
 * (`core/domain/bolivian_phone_number.dart`).
 */
export const BOLIVIA_COUNTRY_CODE = '591';

const MOBILE_PATTERN = /^[67]\d{7}$/;

/** Keeps only the digits and drops a leading country code. */
export function normalizePhone(input: string): string {
  const digits = input.replace(/\D/g, '');
  return digits.length === 11 && digits.startsWith(BOLIVIA_COUNTRY_CODE)
    ? digits.slice(BOLIVIA_COUNTRY_CODE.length)
    : digits;
}

/** 8 digits starting with 6 or 7. */
export function isValidMobile(input: string): boolean {
  return MOBILE_PATTERN.test(normalizePhone(input));
}

/** `7654 3210` */
export function formatPhone(input: string): string {
  const digits = normalizePhone(input);
  return digits.length === 8 ? `${digits.slice(0, 4)} ${digits.slice(4)}` : digits;
}
