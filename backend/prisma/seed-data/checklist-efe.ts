/**
 * Estructura por defecto de la plantilla de checklist, transcrita del
 * documento "792025-PRC-MRV-CHECK-01-RA" (Anexo 1 Check List, Estación
 * Puerto — Levantamiento de información para reposición del sistema de
 * radiocomunicaciones EFE Valparaíso, contrato 79-2025).
 */

export const CHECKLIST_EFE_NOMBRE = 'Anexo 1 · Check List de Estación (Radiocomunicaciones EFE)';

export const CHECKLIST_EFE_DESCRIPCION =
  'Levantamiento de información para reposición de sistema de radiocomunicaciones EFE. ' +
  'Basado en el Anexo 1 Check List del contrato 79-2025 (AltaSistemas / EFE Trenes de Chile).';

export interface SeedItem {
  descripcion: string;
}

export interface SeedGrupo {
  titulo: string;
  items: SeedItem[];
}

export interface SeedSeccion {
  titulo: string;
  grupos: SeedGrupo[];
}

export const CHECKLIST_EFE_SECCIONES: SeedSeccion[] = [
  {
    titulo: 'Información general y coordinación',
    grupos: [
      {
        titulo: 'Contactos clave',
        items: [
          {
            descripcion:
              'Nombres, cargos y datos de contacto de las personas responsables de EFE (operaciones, mantenimiento, seguridad, infraestructura).',
          },
          {
            descripcion:
              'Horarios y restricciones de acceso. Días y horas permitidas para visitas, requisitos de seguridad o acompañamiento.',
          },
          {
            descripcion:
              'Procedimiento de acceso. Necesidad de credenciales, inducciones de seguridad, EPP obligatorio.',
          },
        ],
      },
    ],
  },
  {
    titulo: 'Información por Estación/Sitio existente',
    grupos: [
      {
        titulo: 'Ubicación y acceso',
        items: [
          {
            descripcion:
              'Coordenadas geográficas: latitud, longitud (DATUM WGS84) y altitud (MSNM) exactas de cada estación/sitio.',
          },
          {
            descripcion:
              'Dirección exacta y referencias: dirección postal y puntos de referencia cercanos para facilitar la ubicación.',
          },
          {
            descripcion: 'Tipo de acceso: detalles sobre cómo se llega al sitio (vehicular, peatonal, tren, etc).',
          },
          {
            descripcion:
              'Logística de movilización: espacio para estacionamiento, zonas de carga/descarga, maniobra de vehículos grandes.',
          },
          {
            descripcion:
              'Restricciones de ruido/horario: si hay vecinos, hospitales, etc. que limiten ruidos o trabajos nocturnos.',
          },
        ],
      },
      {
        titulo: 'Infraestructura civil y edificación',
        items: [
          { descripcion: 'Plantas arquitectónicas, cortes y elevaciones (si se dispone de ellas).' },
          { descripcion: 'Dimensiones exactas de la sala técnica (largo, ancho, alto).' },
          {
            descripcion: 'Disponibilidad de espacio en racks existentes (unidades "U" libres, profundidad, ancho).',
          },
          { descripcion: 'Espacio en piso libre para nuevos racks o equipos (dimensiones).' },
          { descripcion: 'Capacidad de carga de la losa/piso de la sala técnica.' },
          {
            descripcion:
              'Condición general de la sala (humedad, filtraciones, temperatura, ventilación natural/forzada, limpieza, presencia de plagas).',
          },
          {
            descripcion:
              'Dimensiones y tipo de las puertas de acceso a la sala técnica para el ingreso de equipos.',
          },
          { descripcion: 'Sistema de detección y extinción de incendios (existencia, tipo, estado).' },
        ],
      },
      {
        titulo: 'Pasadas de cable',
        items: [
          { descripcion: 'Ubicación, tipo (bandejas, ductos, tuberías) y dimensiones.' },
          { descripcion: 'Capacidad libre remanente en las pasadas/bandejas.' },
          { descripcion: 'Estado del sellado de las pasadas (prevención de agua, polvo, roedores).' },
          { descripcion: 'Necesidad de nuevas perforaciones (material de pared/losa, diámetro, permisos).' },
        ],
      },
      {
        titulo: 'Infraestructura Eléctrica',
        items: [
          { descripcion: 'Tipo de alimentación (monofásica, trifásica).' },
          { descripcion: 'Tensión y frecuencia.' },
          {
            descripcion: 'Disponibilidad y capacidad de protecciones (breakers) en tableros eléctricos.',
          },
          { descripcion: 'Espacios libres en tableros existentes para nuevos disyuntores.' },
          { descripcion: 'Distancia de empalmes eléctricos existentes desde el sitio.' },
        ],
      },
      {
        titulo: 'Sistema de respaldo',
        items: [
          {
            descripcion: 'Existencia y características de UPS (VA, tiempo de autonomía, tipo de baterías, antigüedad).',
          },
          {
            descripcion:
              'Existencia y características del grupo electrógeno (KVA, combustible, autonomía, sistema de transferencia automática, historial de mantenimiento).',
          },
          { descripcion: 'Tomas de corriente disponibles (tipo, cantidad).' },
        ],
      },
      {
        titulo: 'Sistema de tierra',
        items: [
          {
            descripcion:
              'Existencia y ubicación de la barra de tierra principal y puntos de conexión en la sala técnica.',
          },
          { descripcion: 'Calidad visual de las conexiones de tierra.' },
        ],
      },
      {
        titulo: 'Climatización y ventilación',
        items: [
          { descripcion: 'Existencia y tipo de sistema de climatización (aire acondicionado, ventilación forzada).' },
          { descripcion: 'Capacidad del sistema (BTU/h o toneladas de refrigeración).' },
          { descripcion: 'Estado de mantenimiento y operatividad.' },
          { descripcion: 'Temperaturas promedio y máximas/mínimas dentro de la sala.' },
          { descripcion: 'Posibilidad de ventilación natural.' },
        ],
      },
      {
        titulo: 'Seguridad del sitio',
        items: [
          { descripcion: 'Tipo de acceso (llave, tarjeta, biométrico, etc).' },
          { descripcion: 'Sistemas de alarma existentes (incendio, intrusión).' },
          { descripcion: 'Sistemas de CCTV (cámaras, cobertura).' },
          { descripcion: 'Seguridad perimetral (muros, rejas, concertinas).' },
        ],
      },
      {
        titulo: 'Estructuras de antenas existentes',
        items: [
          { descripcion: 'Tipo de estructura (monoposte, torre arriostrada/autosoportada, mástil adosado, etc).' },
          { descripcion: 'Altura total de la estructura.' },
          { descripcion: 'Dimensiones de la estructura (diámetro de monoposte, sección de torre).' },
          { descripcion: 'Planos estructurales "As-Built" y cálculos de carga (si aplica).' },
          {
            descripcion:
              'Características de las antenas: modelo, fabricante, ganancia (dBi/dBd), patrón de radiación (horizontal/vertical).',
          },
          { descripcion: 'Capacidad de carga remanente para nuevas antenas y cableado.' },
          { descripcion: 'Espacio disponible para nuevas antenas (alturas, separación vertical/horizontal).' },
          { descripcion: 'Condición física de la estructura (óxido, fisuras, pernos, pintura).' },
          { descripcion: 'Existencia y estado de escalerillas, líneas de vida y sistemas anticaídas.' },
          { descripcion: 'Iluminación de balizamiento de aviación (existencia, tipo, estado).' },
          { descripcion: 'Puesta a tierra de la estructura (conexiones, estado).' },
          {
            descripcion:
              'Tipo de techo (si la antena está en el techo): capacidad de carga, posibilidad de instalar mástiles/soportes.',
          },
        ],
      },
    ],
  },
];
