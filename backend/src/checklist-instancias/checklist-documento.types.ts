/**
 * Forma de los datos que necesitan los generadores de documento (PDF y
 * Word) para renderizar un checklist. Vive en un archivo aparte para que
 * ambos generadores compartan exactamente la misma estructura.
 */

export type LogoUrls = {
  logoEmpresaUrl: string | null;
  logoClienteUrl: string | null;
  logoEmpresaKey: string | null;
  logoClienteKey: string | null;
};

export type ItemDetalle = {
  descripcion: string;
  requiereObservacion: boolean;
  valor: 'SI' | 'NO' | null;
  observaciones: string | null;
};

export type GrupoDetalle = { titulo: string; items: ItemDetalle[] };

export type SeccionDetalle = {
  numero: number;
  titulo: string;
  items: ItemDetalle[];
  grupos: GrupoDetalle[];
};

export type FirmaDetalle = {
  rolNombre: string;
  orden: number;
  nombrePersona: string | null;
  fecha: Date | string | null;
  firmaKey: string | null;
  /** Se sobrescribe con un data URI (PDF) o buffer (Word) antes de renderizar. */
  firmaUrl?: string | null;
};

export type AprobacionRevision = { rol: string; valor?: string | null };

export type RevisionDetalle = {
  revision: string;
  descripcion: string;
  aprobaciones: AprobacionRevision[] | null;
};

export type ChecklistInstanciaDetalle = LogoUrls & {
  nombre: string;
  estacion: string | null;
  contratoNumero: string | null;
  numeroDocumentoCliente: string | null;
  numeroDocumentoInterno: string | null;
  revisionActual: string;
  fecha: Date | string | null;
  comentarios: string | null;
  secciones: SeccionDetalle[];
  firmas: FirmaDetalle[];
  revisiones: RevisionDetalle[];
};
