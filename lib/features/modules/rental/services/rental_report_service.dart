import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rent_car/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../../../home/models/dashboard_models.dart';
import '../models/rental_model.dart';
import '../providers/rental_provider.dart';
import 'package:intl/intl.dart';

class RentalReportService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  // Formateador de moneda para República Dominicana
  static String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return 'RD\$${formatter.format(amount)}';
  }

  /// Genera y descarga un reporte PDF de rentas con filtros
  Future<bool> generatePDFReport({
    required RentalProvider rentalProvider,
    DateTime? startDate,
    DateTime? endDate,
    String? vehicleType,
    String? status,
    bool includeCharts = true,
    bool includeSummary = true,
  }) async {
    try {
      final filters = RentalReportFilters(
        startDate: startDate,
        endDate: endDate,
        vehicleType: vehicleType,
        status: status,
      );

      final config = ReportConfig(
        title: 'Reporte de Rentas',
        description: _buildReportDescription(filters),
        includeCharts: includeCharts,
        includeSummary: includeSummary,
        columns: [
          'No. Renta',
          'Cliente',
          'Vehículo',
          'Fecha Renta',
          'Fecha Devolución',
          'Estado',
          'Monto Total',
          'Empleado'
        ],
      );

      // Obtener datos de rentas desde el provider (datos ya cargados en memoria)
      print(' Obteniendo rentas desde el provider...');
      final allRentals = rentalProvider.todasRentas;
      print('📊 Total rentas en provider: ${allRentals.length}');

      // Aplicar filtros a los datos del provider
      final rentals = _applyFilters(allRentals, filters);
      print('📊 Rentas después de filtrar: ${rentals.length}');

      // Generar PDF siempre, incluso si no hay datos (para mostrar reporte vacío)
      final pdfBytes = await _generatePDF(rentals, config, filters);
      await _downloadPDF(pdfBytes, _generateFileName(filters));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Aplica filtros a la lista de rentas
  List<Rental> _applyFilters(List<Rental> allRentals, RentalReportFilters filters) {
    // Validar que la lista no sea nula
    if (allRentals == null) {
      return [];
    }

    // Si no hay filtros, devolver todas las rentas
    if (filters.startDate == null &&
        filters.endDate == null &&
        (filters.vehicleType == null || filters.vehicleType!.isEmpty) &&
        (filters.status == null || filters.status!.isEmpty)) {
      print(' Sin filtros aplicados, devolviendo todas las rentas');
      var sortedRentals = List<Rental>.from(allRentals);
      sortedRentals.sort((a, b) => b.fechaRenta.compareTo(a.fechaRenta));
      return sortedRentals;
    }

    // Aplicar filtros
    var filteredRentals = allRentals.where((rental) {
      // Filtro por fecha de inicio
      if (filters.startDate != null) {
        final rentalDate = DateTime(rental.fechaRenta.year, rental.fechaRenta.month, rental.fechaRenta.day);
        final filterStartDate = DateTime(filters.startDate!.year, filters.startDate!.month, filters.startDate!.day);
        if (rentalDate.isBefore(filterStartDate)) {
          print('Renta ${rental.noRenta} excluida por fecha inicio: ${rental.fechaRenta} < ${filters.startDate}');
          return false;
        }
      }

      // Filtro por fecha de fin
      if (filters.endDate != null) {
        final rentalDate = DateTime(rental.fechaRenta.year, rental.fechaRenta.month, rental.fechaRenta.day);
        final filterEndDate = DateTime(filters.endDate!.year, filters.endDate!.month, filters.endDate!.day);
        if (rentalDate.isAfter(filterEndDate)) {
          print('Renta ${rental.noRenta} excluida por fecha fin: ${rental.fechaRenta} > ${filters.endDate}');
          return false;
        }
      }

      // Filtro por tipo de vehículo
      if (filters.vehicleType != null && filters.vehicleType!.isNotEmpty) {
        final vehicleTypeDesc = rental.vehiculo?.tipoVehiculo?.descripcion?.toLowerCase();
        if (vehicleTypeDesc == null || !vehicleTypeDesc.contains(filters.vehicleType!.toLowerCase())) {
          print('Renta ${rental.noRenta} excluida por tipo vehículo: $vehicleTypeDesc no contiene ${filters.vehicleType}');
          return false;
        }
      }

      // Filtro por estado
      if (filters.status != null && filters.status!.isNotEmpty) {
        final rentalStatus = rental.estado.toString().split('.').last;
        if (rentalStatus != filters.status) {
          print('Renta ${rental.noRenta} excluida por estado: $rentalStatus != ${filters.status}');
          return false;
        }
      }

      print(' Renta ${rental.noRenta} incluida en el reporte');
      return true;
    }).toList();

    // Ordenar por fecha de renta descendente
    filteredRentals.sort((a, b) => b.fechaRenta.compareTo(a.fechaRenta));

    return filteredRentals;
  }


  /// Descarga el archivo PDF para web
  Future<void> _downloadPDF(Uint8List pdfBytes, String fileName) async {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();

    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  /// Genera un nombre de archivo descriptivo
  String _generateFileName(RentalReportFilters filters) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    String suffix = '';
    if (filters.startDate != null && filters.endDate != null) {
      final start = filters.startDate!;
      final end = filters.endDate!;
      suffix = '_${start.day}-${start.month}-${start.year}_al_${end.day}-${end.month}-${end.year}';
    }

    return 'reporte_rentas_$dateStr$suffix.pdf';
  }

  /// Construye la descripción del reporte
  String _buildReportDescription(RentalReportFilters filters) {
    final parts = <String>[];

    if (filters.startDate != null && filters.endDate != null) {
      parts.add('Período: ${_formatDate(filters.startDate!)} - ${_formatDate(filters.endDate!)}');
    }

    if (filters.vehicleType != null) {
      parts.add('Tipo de vehículo: ${filters.vehicleType}');
    }

    if (filters.status != null) {
      parts.add('Estado: ${filters.status}');
    }

    return parts.isEmpty
        ? 'Reporte general de todas las rentas'
        : 'Reporte filtrado - ${parts.join(', ')}';
  }

  /// Formatea una fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Genera un PDF profesional con el paquete pdf
  Future<Uint8List> _generatePDF(List<Rental> rentals, ReportConfig config, RentalReportFilters filters) async {
    final pdf = pw.Document();

    // Validar que las listas no sean nulas
    final safeRentals = rentals;
    final safeColumns = config.columns;

    // Cargar fuente que soporte Unicode
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    // Calcular estadísticas mejoradas con validación
    final active = safeRentals.where((r) => r.estadoCalculado == EstadoRenta.ACTIVA).length;
    final completed = safeRentals.where((r) => r.estadoCalculado == EstadoRenta.DEVUELTA).length;
    final overdue = safeRentals.where((r) => r.estadoCalculado == EstadoRenta.VENCIDA).length;
    final canceled = safeRentals.where((r) => r.estadoCalculado == EstadoRenta.CANCELADA).length;
    final totalRevenue = safeRentals.fold<double>(0, (sum, r) => sum + (r.montoTotal));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header compacto
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [PdfColors.blue900, PdfColors.blue700],
                ),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    config.title,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      font: fontBold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    config.description,
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.white, font: font),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Fecha de generación: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey300, font: font),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Summary Section compacto
            if (config.includeSummary) ...[
              pw.Text(
                'Resumen Ejecutivo',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: fontBold, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompactSummaryItem('Total', '${safeRentals.length}', PdfColors.blue600, font, fontBold),
                    _buildCompactSummaryItem('Activas', '$active', PdfColors.green600, font, fontBold),
                    _buildCompactSummaryItem('Completadas', '$completed', PdfColors.blue500, font, fontBold),
                    _buildCompactSummaryItem('Vencidas', '$overdue', PdfColors.orange600, font, fontBold),
                    _buildCompactSummaryItem('Canceladas', '$canceled', PdfColors.red600, font, fontBold),
                    _buildCompactSummaryItem('Ingresos', _formatCurrency(totalRevenue), PdfColors.green700, font, fontBold),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // Table Header compacto
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Detalle de Rentas (${safeRentals.length} registros)',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: fontBold, color: PdfColors.blue900),
                ),
                if (safeRentals.isEmpty)
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange100,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: PdfColors.orange300),
                    ),
                    child: pw.Text(
                      'Sin datos',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.orange800, font: fontBold),
                    ),
                  ),
              ],
            ),
            pw.SizedBox(height: 8),

            // Tabla de rentas o mensaje de datos vacíos
            if (safeRentals.isEmpty)
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(40),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  children: [
                    pw.Icon(
                      pw.IconData(0xe88f), // Icon for no data
                      size: 48,
                      color: PdfColors.grey400,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'No se encontraron rentas',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: fontBold, color: PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Con los filtros aplicados no se encontraron rentas para mostrar.',
                      style: pw.TextStyle(fontSize: 12, font: font, color: PdfColors.grey500),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: pw.FixedColumnWidth(35),   // No. Renta
                  1: pw.FlexColumnWidth(2),    // Cliente
                  2: pw.FlexColumnWidth(2),    // Vehículo
                  3: pw.FixedColumnWidth(55),  // Fecha Renta
                  4: pw.FixedColumnWidth(55),  // Fecha Devolución
                  5: pw.FixedColumnWidth(50),  // Estado
                  6: pw.FixedColumnWidth(60),  // Monto
                  7: pw.FlexColumnWidth(1.5),  // Empleado
                },
                children: [
                  // Header Row mejorado
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.blue900),
                    children: safeColumns.map((col) =>
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          col,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            fontSize: 9,
                            font: fontBold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ).toList(),
                  ),
                  // Data Rows mejoradas
                  ...safeRentals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final rental = entry.value;
                    return _buildRentalRow(rental, font, index);
                  }),
                ],
              ),

            pw.SizedBox(height: 20),

            // Footer compacto
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Reporte generado por Sistema GoVia RentCar',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900, font: fontBold),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Universidad APEC - Proyecto de Exoneración',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, font: font),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Generado el ${_formatDate(DateTime.now())} a las ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500, font: font),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildCompactSummaryItem(String label, String value, PdfColor color, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
            font: fontBold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey700,
            font: font,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.TableRow _buildRentalRow(Rental? rental, pw.Font font, int index) {
    final isEven = index % 2 == 0;
    final backgroundColor = isEven ? PdfColors.white : PdfColors.grey50;

    // Validar que rental no sea nulo
    if (rental == null) {
      return pw.TableRow(
        decoration: pw.BoxDecoration(color: backgroundColor),
        children: List.generate(8, (i) => pw.Container(
          padding: pw.EdgeInsets.all(8),
          child: pw.Text('N/A', style: pw.TextStyle(fontSize: 9, font: font)),
        )),
      );
    }

    // Determinar color del estado
    PdfColor statusColor = PdfColors.grey600;
    switch (rental.estadoCalculado) {
      case EstadoRenta.ACTIVA:
        statusColor = PdfColors.green600;
        break;
      case EstadoRenta.DEVUELTA:
        statusColor = PdfColors.blue600;
        break;
      case EstadoRenta.VENCIDA:
        statusColor = PdfColors.orange600;
        break;
      case EstadoRenta.CANCELADA:
        statusColor = PdfColors.red600;
        break;
      default:
        statusColor = PdfColors.grey600;
    }

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: backgroundColor),
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            '${rental.noRenta ?? 'N/A'}',
            style: pw.TextStyle(fontSize: 8, font: font, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            rental.cliente?.nombre ?? 'Sin cliente',
            style: pw.TextStyle(fontSize: 7, font: font),
            maxLines: 2,
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                rental.vehiculo?.descripcion ?? 'Sin vehículo',
                style: pw.TextStyle(fontSize: 7, font: font),
                maxLines: 1,
              ),
              if (rental.vehiculo?.noPlaca != null)
                pw.Text(
                  '${rental.vehiculo!.noPlaca}',
                  style: pw.TextStyle(fontSize: 6, font: font, color: PdfColors.grey600),
                ),
            ],
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            _formatDate(rental.fechaRenta),
            style: pw.TextStyle(fontSize: 7, font: font),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            rental.fechaDevolucion != null ? _formatDate(rental.fechaDevolucion!) : 'N/A',
            style: pw.TextStyle(
              fontSize: 7,
              font: font,
              color: rental.fechaDevolucion != null ? PdfColors.grey700 : PdfColors.orange600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Text(
              rental.estadoDescripcion,
              style: pw.TextStyle(
                fontSize: 6,
                font: font,
                fontWeight: pw.FontWeight.bold,
                color: statusColor,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            _formatCurrency(rental.montoTotal),
            style: pw.TextStyle(
              fontSize: 7,
              font: font,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
            rental.empleado?.nombre ?? 'N/A',
            style: pw.TextStyle(fontSize: 7, font: font),
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}