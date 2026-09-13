import { Injectable } from '@nestjs/common';
import sharp from 'sharp';
import {
  AlignmentType,
  BorderStyle,
  Document,
  HeadingLevel,
  ImageRun,
  Packer,
  Paragraph,
  ShadingType,
  Table,
  TableCell,
  TableRow,
  TextRun,
  VerticalAlignTable,
  WidthType,
} from 'docx';
import { StorageService } from '../storage/storage.service';
import type {
  AprobacionRevision,
  ChecklistInstanciaDetalle,
  FirmaDetalle,
  GrupoDetalle,
  ItemDetalle,
  SeccionDetalle,
} from './checklist-documento.types';

const AZUL = '2E5C8A';
const AZUL_CLARO = 'DCE7F1';
const GRIS_BORDE = '999999';

type Imagen = { data: Buffer; width: number; height: number };

@Injectable()
export class ChecklistDocxService {
  constructor(private readonly storage: StorageService) {}

  private async cargarImagen(key: string | null | undefined, maxWidth: number, maxHeight: number): Promise<Imagen | null> {
    if (!key) return null;
    try {
      const buffer = await this.storage.getObjectBuffer(key);
      const metadata = await sharp(buffer).metadata();
      const natW = metadata.width ?? maxWidth;
      const natH = metadata.height ?? maxHeight;
      const scale = Math.min(maxWidth / natW, maxHeight / natH, 1);
      // docx sólo sabe incrustar PNG/JPEG/GIF/BMP: cualquier otro formato
      // (o uno que sharp no logre decodificar, ej. HEIC real de iPhone) se
      // reconvierte a PNG primero.
      const png = await sharp(buffer).png().toBuffer();
      return { data: png, width: Math.round(natW * scale), height: Math.round(natH * scale) };
    } catch {
      return null;
    }
  }

  private fecha(value: Date | string | null): string {
    if (!value) return '';
    const d = new Date(value);
    return d.toLocaleDateString('es-CL', { timeZone: 'UTC' });
  }

  private textoSimple(texto: string, opciones: { bold?: boolean; size?: number; color?: string } = {}): Paragraph {
    return new Paragraph({
      children: [new TextRun({ text: texto || '', bold: opciones.bold, size: opciones.size, color: opciones.color })],
    });
  }

  private celda(
    children: (Paragraph | Table)[],
    opciones: {
      shading?: string;
      width?: number;
      columnSpan?: number;
      verticalAlign?: (typeof VerticalAlignTable)[keyof typeof VerticalAlignTable];
    } = {},
  ): TableCell {
    return new TableCell({
      children,
      columnSpan: opciones.columnSpan,
      verticalAlign: opciones.verticalAlign ?? VerticalAlignTable.CENTER,
      width: opciones.width ? { size: opciones.width, type: WidthType.PERCENTAGE } : undefined,
      shading: opciones.shading
        ? { type: ShadingType.CLEAR, color: 'auto', fill: opciones.shading }
        : undefined,
      margins: { top: 80, bottom: 80, left: 100, right: 100 },
    });
  }

  private async filaFirmantes(firmas: FirmaDetalle[]): Promise<Table> {
    const ordenadas = [...firmas].sort((a, b) => a.orden - b.orden);
    const ancho = 100 / Math.max(ordenadas.length, 1);

    const headerRow = new TableRow({
      children: ordenadas.map((f) =>
        this.celda([this.textoSimple(f.rolNombre.toUpperCase(), { bold: true })], {
          shading: AZUL_CLARO,
          width: ancho,
        }),
      ),
    });

    const celdas: TableCell[] = [];
    for (const f of ordenadas) {
      const imagen = await this.cargarImagen(f.firmaKey, 220, 70);
      const contenido: Paragraph[] = [
        new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [new TextRun({ text: f.nombrePersona ?? '', bold: true })],
        }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [new TextRun({ text: this.fecha(f.fecha), color: '555555', size: 18 })],
        }),
      ];
      if (imagen) {
        contenido.push(
          new Paragraph({
            alignment: AlignmentType.CENTER,
            border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: GRIS_BORDE } },
            children: [
              new ImageRun({
                type: 'png',
                data: imagen.data,
                transformation: { width: imagen.width, height: imagen.height },
              }),
            ],
          }),
        );
      } else {
        contenido.push(
          new Paragraph({
            border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: GRIS_BORDE } },
            spacing: { before: 300 },
            children: [new TextRun({ text: '' })],
          }),
        );
      }
      celdas.push(this.celda(contenido, { width: ancho, verticalAlign: VerticalAlignTable.BOTTOM }));
    }

    return new Table({
      width: { size: 100, type: WidthType.PERCENTAGE },
      rows: [headerRow, new TableRow({ children: celdas })],
    });
  }

  private tablaRevisiones(
    firmas: FirmaDetalle[],
    revisiones: { revision: string; descripcion: string; aprobaciones: AprobacionRevision[] | null }[],
  ): Table | null {
    const roles = firmas.map((f) => f.rolNombre);
    if (roles.length === 0) return null;

    const anchoBase = 60 / (roles.length || 1);
    const headerRow = new TableRow({
      children: [
        this.celda([this.textoSimple('REV N°', { bold: true, color: 'FFFFFF' })], { shading: AZUL, width: 10 }),
        this.celda([this.textoSimple('DESCRIPCIÓN', { bold: true, color: 'FFFFFF' })], { shading: AZUL, width: 30 }),
        ...roles.map((r) =>
          this.celda([this.textoSimple(r, { bold: true, color: 'FFFFFF' })], { shading: AZUL, width: anchoBase }),
        ),
      ],
    });

    const filas =
      revisiones.length > 0
        ? revisiones.map(
            (r) =>
              new TableRow({
                children: [
                  this.celda([this.textoSimple(r.revision)], { width: 10 }),
                  this.celda([this.textoSimple(r.descripcion)], { width: 30 }),
                  ...roles.map((rol) => {
                    const aprobacion = r.aprobaciones?.find((a) => a.rol === rol);
                    return this.celda([this.textoSimple(aprobacion?.valor ?? '')], { width: anchoBase });
                  }),
                ],
              }),
          )
        : [
            new TableRow({
              children: [this.celda([this.textoSimple('')], { columnSpan: 2 + roles.length })],
            }),
          ];

    return new Table({ width: { size: 100, type: WidthType.PERCENTAGE }, rows: [headerRow, ...filas] });
  }

  private filaItem(numero: string, item: ItemDetalle): TableRow {
    return new TableRow({
      children: [
        this.celda([new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun(numero)] })], {
          width: 6,
        }),
        this.celda([this.textoSimple(item.descripcion)], { width: 34 }),
        this.celda(
          [
            new Paragraph({
              alignment: AlignmentType.CENTER,
              children: [new TextRun({ text: item.valor === 'SI' ? 'X' : '', bold: true })],
            }),
          ],
          { width: 6 },
        ),
        this.celda(
          [
            new Paragraph({
              alignment: AlignmentType.CENTER,
              children: [new TextRun({ text: item.valor === 'NO' ? 'X' : '', bold: true })],
            }),
          ],
          { width: 6 },
        ),
        this.celda([this.textoSimple(item.observaciones ?? '')], { width: 48 }),
      ],
    });
  }

  private tablaSeccion(seccion: SeccionDetalle): Table {
    const headerRow = new TableRow({
      children: [
        this.celda([this.textoSimple(String(seccion.numero), { bold: true, color: 'FFFFFF' })], {
          shading: AZUL,
          width: 6,
        }),
        this.celda([this.textoSimple(seccion.titulo, { bold: true, color: 'FFFFFF' })], { shading: AZUL, width: 34 }),
        this.celda([this.textoSimple('SI', { bold: true, color: 'FFFFFF' })], { shading: AZUL, width: 6 }),
        this.celda([this.textoSimple('NO', { bold: true, color: 'FFFFFF' })], { shading: AZUL, width: 6 }),
        this.celda([this.textoSimple('Observaciones', { bold: true, color: 'FFFFFF' })], { shading: AZUL, width: 48 }),
      ],
    });

    const filas: TableRow[] = seccion.items.map((item, idx) => this.filaItem(`${seccion.numero}.${idx + 1}`, item));

    let contador = seccion.items.length;
    for (const grupo of seccion.grupos as GrupoDetalle[]) {
      filas.push(
        new TableRow({
          children: [this.celda([this.textoSimple(grupo.titulo, { bold: true })], { shading: AZUL_CLARO, columnSpan: 5 })],
        }),
      );
      for (const item of grupo.items) {
        contador += 1;
        filas.push(this.filaItem(`${seccion.numero}.${contador}`, item));
      }
    }

    return new Table({ width: { size: 100, type: WidthType.PERCENTAGE }, rows: [headerRow, ...filas] });
  }

  async generar(instancia: ChecklistInstanciaDetalle): Promise<Buffer> {
    const [logoEmpresa, logoCliente] = await Promise.all([
      this.cargarImagen(instancia.logoEmpresaKey, 130, 45),
      this.cargarImagen(instancia.logoClienteKey, 160, 60),
    ]);

    const portadaChildren: (Paragraph | Table)[] = [];

    const logosFila: Paragraph[] = [];
    if (logoEmpresa) {
      logosFila.push(
        new Paragraph({
          children: [
            new ImageRun({
              type: 'png',
              data: logoEmpresa.data,
              transformation: { width: logoEmpresa.width, height: logoEmpresa.height },
            }),
          ],
        }),
      );
    }
    if (logoCliente) {
      logosFila.push(
        new Paragraph({
          alignment: AlignmentType.RIGHT,
          children: [
            new ImageRun({
              type: 'png',
              data: logoCliente.data,
              transformation: { width: logoCliente.width, height: logoCliente.height },
            }),
          ],
        }),
      );
    }
    portadaChildren.push(...logosFila);

    portadaChildren.push(
      new Paragraph({ spacing: { before: 400 }, children: [] }),
      new Paragraph({
        heading: HeadingLevel.TITLE,
        children: [new TextRun({ text: instancia.nombre, bold: true, size: 32 })],
      }),
      new Paragraph({
        alignment: AlignmentType.RIGHT,
        children: [new TextRun({ text: 'Anexo 1 Check list', bold: true, size: 26 })],
      }),
      new Paragraph({
        alignment: AlignmentType.RIGHT,
        children: [new TextRun({ text: instancia.estacion ?? '', bold: true, size: 26 })],
      }),
      new Paragraph({
        border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: 'C0392B' } },
        spacing: { before: 200, after: 300 },
        children: [],
      }),
      new Paragraph({
        children: [
          new TextRun({ text: 'CONTRATO N°: ', bold: true, color: AZUL }),
          new TextRun({ text: instancia.contratoNumero ?? '' }),
        ],
      }),
      new Paragraph({
        children: [
          new TextRun({ text: 'ESTACIÓN: ', bold: true, color: AZUL }),
          new TextRun({ text: instancia.estacion ?? '' }),
        ],
      }),
      new Paragraph({
        children: [
          new TextRun({ text: 'N° DOCUMENTO CLIENTE: ', bold: true, color: AZUL }),
          new TextRun({ text: instancia.numeroDocumentoCliente ?? '' }),
        ],
      }),
      new Paragraph({
        children: [
          new TextRun({ text: 'N° DOCUMENTO ALTASISTEMAS: ', bold: true, color: AZUL }),
          new TextRun({ text: instancia.numeroDocumentoInterno ?? '' }),
        ],
      }),
      new Paragraph({
        children: [
          new TextRun({ text: 'REVISIÓN: ', bold: true, color: AZUL }),
          new TextRun({ text: `"${instancia.revisionActual}"` }),
        ],
      }),
      new Paragraph({
        children: [
          new TextRun({ text: 'FECHA: ', bold: true, color: AZUL }),
          new TextRun({ text: this.fecha(instancia.fecha) }),
        ],
      }),
    );

    const aprobacionChildren: (Paragraph | Table)[] = [
      new Paragraph({
        pageBreakBefore: true,
        heading: HeadingLevel.HEADING_2,
        children: [new TextRun(`Anexo 1 · Check list · ${instancia.estacion ?? ''}`)],
      }),
    ];
    if (instancia.firmas.length > 0) {
      aprobacionChildren.push(await this.filaFirmantes(instancia.firmas));
      aprobacionChildren.push(new Paragraph({ spacing: { before: 300 }, children: [] }));
    }
    const tablaRev = this.tablaRevisiones(instancia.firmas, instancia.revisiones);
    if (tablaRev) {
      aprobacionChildren.push(tablaRev);
    }

    const checklistChildren: (Paragraph | Table)[] = [
      new Paragraph({ pageBreakBefore: true, heading: HeadingLevel.HEADING_2, children: [new TextRun('Check list')] }),
    ];
    for (const seccion of instancia.secciones) {
      checklistChildren.push(this.tablaSeccion(seccion));
      checklistChildren.push(new Paragraph({ spacing: { before: 200, after: 200 }, children: [] }));
    }

    const comentariosChildren: (Paragraph | Table)[] = [
      new Paragraph({ pageBreakBefore: true, heading: HeadingLevel.HEADING_2, children: [new TextRun('Comentarios')] }),
      new Table({
        width: { size: 100, type: WidthType.PERCENTAGE },
        rows: [
          new TableRow({
            children: [
              this.celda(
                (instancia.comentarios ?? '')
                  .split('\n')
                  .map((linea) => this.textoSimple(linea))
                  .concat(instancia.comentarios ? [] : [this.textoSimple('')]),
              ),
            ],
          }),
        ],
      }),
    ];

    const doc = new Document({
      sections: [
        {
          properties: {},
          children: [
            ...portadaChildren,
            ...aprobacionChildren,
            ...checklistChildren,
            ...comentariosChildren,
          ],
        },
      ],
    });

    return Packer.toBuffer(doc);
  }
}
