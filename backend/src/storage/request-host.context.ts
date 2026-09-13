import { AsyncLocalStorage } from 'async_hooks';

/**
 * Guarda el "Host" con el que el navegador pidió la página actual (ej.
 * "192.168.1.50:8080" o "localhost:8080"), para poder firmar URLs de MinIO
 * usando ese mismo host en vez de uno fijo por variable de entorno. Así las
 * URLs firmadas funcionan sin importar si se accede por localhost, IP de LAN
 * o un dominio real, sin tener que reconfigurar nada por dispositivo.
 */
export const requestHostContext = new AsyncLocalStorage<{ host?: string }>();
