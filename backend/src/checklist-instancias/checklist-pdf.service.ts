import { Injectable } from '@nestjs/common';
import puppeteer from 'puppeteer';

type LogoUrls = { logoEmpresaUrl: string | null; logoClienteUrl: string | null };

type ItemDetalle = {
  descripcion: string;
  requiereObservacion: boolean;
  valor: 'SI' | 'NO' | null;
  observaciones: string | null;
};

type GrupoDetalle = { titulo: string; items: ItemDetalle[] };

type SeccionDetalle = {
  numero: number;
  titulo: string;
  items: ItemDetalle[];
  grupos: GrupoDetalle[];
};

type RevisionDetalle = {
  revision: string;
  descripcion: string;
  aprobacionGerenciaGeneral: string | null;
  aprobacionDeptoIngenieria: string | null;
  aprobacionClienteJefeProyecto: string | null;
};

export type ChecklistInstanciaDetalle = LogoUrls & {
  nombre: string;
  estacion: string | null;
  contratoNumero: string | null;
  numeroDocumentoCliente: string | null;
  numeroDocumentoInterno: string | null;
  revisionActual: string;
  fecha: Date | string | null;
  preparadoPorNombre: string | null;
  preparadoPorFecha: Date | string | null;
  revisadoPorNombre: string | null;
  revisadoPorFecha: Date | string | null;
  aprobadoPorNombre: string | null;
  aprobadoPorFecha: Date | string | null;
  comentarios: string | null;
  secciones: SeccionDetalle[];
  revisiones: RevisionDetalle[];
};

const AZUL = '#2E5C8A';
const AZUL_CLARO = '#DCE7F1';

@Injectable()
export class ChecklistPdfService {
  async generar(instancia: ChecklistInstanciaDetalle): Promise<Buffer> {
    const html = this.renderHtml(instancia);
    const browser = await puppeteer.launch({
      headless: true,
      executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || undefined,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });
    try {
      const page = await browser.newPage();
      await page.setContent(html, { waitUntil: 'load' });
      const pdf = await page.pdf({
        format: 'A4',
        printBackground: true,
        margin: { top: '20mm', bottom: '18mm', left: '15mm', right: '15mm' },
        displayHeaderFooter: true,
        headerTemplate: '<span></span>',
        footerTemplate: `
          <div style="font-size:8px; width:100%; padding:0 15mm; display:flex; justify-content:space-between; color:#555;">
            <span>AltaSistemas · ${this.esc(instancia.nombre)}</span>
            <span>Página <span class="pageNumber"></span> | <span class="totalPages"></span></span>
          </div>`,
      });
      return Buffer.from(pdf);
    } finally {
      await browser.close();
    }
  }

  private esc(value: unknown): string {
    return String(value ?? '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  private fecha(value: Date | string | null): string {
    if (!value) return '';
    // Las fechas se guardan como calendario puro (sin hora); se formatean en
    // UTC para que no se corran un día según la zona horaria del servidor.
    const d = new Date(value);
    return d.toLocaleDateString('es-CL', { timeZone: 'UTC' });
  }

  private renderItemRow(numero: string, item: ItemDetalle): string {
    return `
      <tr>
        <td class="col-num">${this.esc(numero)}</td>
        <td class="col-desc">${this.esc(item.descripcion)}</td>
        <td class="col-check">${item.valor === 'SI' ? 'X' : ''}</td>
        <td class="col-check">${item.valor === 'NO' ? 'X' : ''}</td>
        <td class="col-obs">${this.esc(item.observaciones).replace(/\n/g, '<br/>')}</td>
      </tr>`;
  }

  private renderSeccion(seccion: SeccionDetalle): string {
    const headerRow = `
      <tr class="seccion-header">
        <td>${seccion.numero}</td>
        <td>${this.esc(seccion.titulo)}</td>
        <td>SI</td>
        <td>NO</td>
        <td>Observaciones</td>
      </tr>`;

    const filasDirectas = seccion.items
      .map((item, idx) => this.renderItemRow(`${seccion.numero}.${idx + 1}`, item))
      .join('');

    let contadorItem = seccion.items.length;
    const filasGrupos = seccion.grupos
      .map((grupo) => {
        const subHeader = `<tr class="grupo-header"><td colspan="5">${this.esc(grupo.titulo)}</td></tr>`;
        const filas = grupo.items
          .map((item) => {
            contadorItem += 1;
            return this.renderItemRow(`${seccion.numero}.${contadorItem}`, item);
          })
          .join('');
        return subHeader + filas;
      })
      .join('');

    return `
      <table class="checklist-table">
        <thead>${headerRow}</thead>
        <tbody>${filasDirectas}${filasGrupos}</tbody>
      </table>`;
  }

  private renderHtml(i: ChecklistInstanciaDetalle): string {
    const logoEmpresa = i.logoEmpresaUrl
      ? `<img src="${i.logoEmpresaUrl}" class="logo-empresa" />`
      : `<div class="logo-placeholder">AltaSistemas</div>`;
    const logoCliente = i.logoClienteUrl
      ? `<img src="${i.logoClienteUrl}" class="logo-cliente" />`
      : '';

    const revisionesRows = i.revisiones.length
      ? i.revisiones
          .map(
            (r) => `
        <tr>
          <td>${this.esc(r.revision)}</td>
          <td>${this.esc(r.descripcion)}</td>
          <td>${this.esc(r.aprobacionGerenciaGeneral)}</td>
          <td>${this.esc(r.aprobacionDeptoIngenieria)}</td>
          <td>${this.esc(r.aprobacionClienteJefeProyecto)}</td>
        </tr>`,
          )
          .join('')
      : '<tr><td colspan="5">&nbsp;</td></tr>';

    return `<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<style>
  * { box-sizing: border-box; }
  body { font-family: Arial, Helvetica, sans-serif; color: #1a1a1a; font-size: 11px; margin: 0; }
  h1 { font-size: 20px; margin: 24px 0 4px; }
  h2 { font-size: 15px; margin: 16px 0 4px; }
  .portada { text-align: center; padding-top: 10px; }
  .logos-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 40px; }
  .logo-empresa { max-height: 40px; }
  .logo-cliente { max-height: 60px; }
  .logo-placeholder { font-weight: bold; color: ${AZUL}; font-size: 18px; }
  .titulo-principal { font-size: 22px; font-weight: bold; text-align: left; margin: 40px 0 10px; text-transform: uppercase; }
  .subtitulo { font-size: 18px; font-weight: bold; text-align: right; margin: 4px 0; }
  hr { border: none; border-top: 2px solid #c0392b; margin: 20px 0; }
  .info-contrato { text-align: left; font-size: 12px; line-height: 1.8; }
  .info-contrato b { color: ${AZUL}; }
  .page-break { page-break-before: always; }
  table.aprobacion { width: 100%; border-collapse: collapse; margin-bottom: 24px; }
  table.aprobacion th, table.aprobacion td { border: 1px solid #999; padding: 8px; text-align: center; font-size: 11px; }
  table.aprobacion th { background: ${AZUL_CLARO}; }
  table.revisiones { width: 100%; border-collapse: collapse; }
  table.revisiones th, table.revisiones td { border: 1px solid #999; padding: 6px; font-size: 10px; text-align: center; }
  table.revisiones th { background: ${AZUL}; color: white; }
  table.checklist-table { width: 100%; border-collapse: collapse; margin-bottom: 14px; table-layout: fixed; }
  table.checklist-table td { border: 1px solid #999; padding: 5px 6px; font-size: 10px; vertical-align: top; word-wrap: break-word; }
  tr.seccion-header td { background: ${AZUL}; color: white; font-weight: bold; }
  tr.grupo-header td { background: ${AZUL_CLARO}; font-weight: bold; }
  .col-num { width: 6%; text-align: center; }
  .col-desc { width: 34%; }
  .col-check { width: 6%; text-align: center; font-weight: bold; }
  .col-obs { width: 48%; }
  .comentarios-box { border: 1px solid #999; min-height: 200px; padding: 10px; white-space: pre-wrap; }
</style>
</head>
<body>

  <section class="portada">
    <div class="logos-row">
      ${logoEmpresa}
      ${logoCliente}
    </div>
    <div class="titulo-principal">${this.esc(i.nombre)}</div>
    <div class="subtitulo">Anexo 1 Check list</div>
    <div class="subtitulo">${this.esc(i.estacion)}</div>
    <hr />
    <div class="info-contrato">
      <div><b>CONTRATO N°:</b> ${this.esc(i.contratoNumero)}</div>
      <div><b>ESTACIÓN:</b> ${this.esc(i.estacion)}</div>
      <div><b>N° DOCUMENTO CLIENTE:</b> ${this.esc(i.numeroDocumentoCliente)}</div>
      <div><b>N° DOCUMENTO ALTASISTEMAS:</b> ${this.esc(i.numeroDocumentoInterno)}</div>
      <div><b>REVISIÓN:</b> "${this.esc(i.revisionActual)}"</div>
      <div><b>FECHA:</b> ${this.fecha(i.fecha)}</div>
    </div>
  </section>

  <section class="page-break">
    <h2>Anexo 1 · Check list · ${this.esc(i.estacion)}</h2>
    <table class="aprobacion">
      <tr>
        <th>PREPARÓ</th>
        <th>REVISÓ</th>
        <th>APROBÓ</th>
      </tr>
      <tr>
        <td>${this.esc(i.preparadoPorNombre)}<br/>${this.fecha(i.preparadoPorFecha)}</td>
        <td>${this.esc(i.revisadoPorNombre)}<br/>${this.fecha(i.revisadoPorFecha)}</td>
        <td>${this.esc(i.aprobadoPorNombre)}<br/>${this.fecha(i.aprobadoPorFecha)}</td>
      </tr>
    </table>

    <table class="revisiones">
      <tr>
        <th rowspan="2">REV N°</th>
        <th rowspan="2">DESCRIPCIÓN</th>
        <th colspan="2">APROBACIÓN ALTASISTEMAS</th>
        <th>APROBACIÓN CLIENTE</th>
      </tr>
      <tr>
        <th>Gerencia General</th>
        <th>Depto. Ingeniería</th>
        <th>Jefe Proyecto</th>
      </tr>
      ${revisionesRows}
    </table>
  </section>

  <section class="page-break">
    <h2>Check list</h2>
    ${i.secciones.map((s) => this.renderSeccion(s)).join('')}
  </section>

  <section class="page-break">
    <h2>Comentarios</h2>
    <div class="comentarios-box">${this.esc(i.comentarios) || '&nbsp;'}</div>
  </section>

</body>
</html>`;
  }
}
