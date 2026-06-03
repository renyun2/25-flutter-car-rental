const { hoursBetween } = require('./date');

const INSURANCE_FEES = {
  none: 0,
  basic: 30,
  full: 80,
};

/**
 * Mixed hour + day pricing: full days at daily_rate, remainder hours at hourly_rate (min 4h total).
 */
function calcRentalFee(dailyRate, hourlyRate, pickupAt, returnAt) {
  const hours = hoursBetween(pickupAt, returnAt);
  if (hours < 4) {
    return { hours, fullDays: 0, extraHours: hours, rentalFee: 0, error: '租期最少 4 小时' };
  }
  const fullDays = Math.floor(hours / 24);
  const extraHours = hours % 24;
  let rentalFee = fullDays * dailyRate;
  if (extraHours > 0) {
    rentalFee += extraHours * hourlyRate;
  } else if (fullDays === 0) {
    rentalFee = hours * hourlyRate;
  }
  return { hours, fullDays, extraHours, rentalFee: Math.round(rentalFee * 100) / 100, error: null };
}

function calcQuote({ dailyRate, hourlyRate, pickupAt, returnAt, insurance = 'none', couponDiscount = 0 }) {
  const base = calcRentalFee(dailyRate, hourlyRate, pickupAt, returnAt);
  if (base.error) return { error: base.error };
  const insuranceFee = INSURANCE_FEES[insurance] ?? 0;
  const subtotal = base.rentalFee + insuranceFee;
  const discount = Math.min(couponDiscount, subtotal);
  const total = Math.max(0, Math.round((subtotal - discount) * 100) / 100);
  return {
    hours: base.hours,
    fullDays: base.fullDays,
    extraHours: base.extraHours,
    rentalFee: base.rentalFee,
    insuranceFee,
    insurance,
    discount,
    subtotal,
    total,
    breakdown: [
      { label: '租金', amount: base.rentalFee },
      { label: '保险', amount: insuranceFee },
      ...(discount > 0 ? [{ label: '优惠', amount: -discount }] : []),
    ],
  };
}

function calcCancelRefund(totalAmount, pickupAt) {
  const { hoursUntilPickup } = require('./date');
  const h = hoursUntilPickup(pickupAt);
  if (h >= 24) {
    return { refund: totalAmount, penalty: 0, rule: '取车前24小时外全额退款' };
  }
  const penalty = Math.round(totalAmount * 0.2 * 100) / 100;
  return {
    refund: Math.round((totalAmount - penalty) * 100) / 100,
    penalty,
    rule: '取车前24小时内取消扣20%违约金',
  };
}

module.exports = { calcRentalFee, calcQuote, calcCancelRefund, INSURANCE_FEES };
