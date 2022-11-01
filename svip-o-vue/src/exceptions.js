/**
 * Occurs when a request for what should be a single gene returns multiple results.
 * @param message
 * @constructor
 */
export function MultiGeneError(message) {
    this.message = message;
    this.name = 'MultiGeneError';
}
