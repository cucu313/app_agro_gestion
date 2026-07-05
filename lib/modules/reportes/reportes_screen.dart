import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'reportes_repository.dart';
import 'export_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen>
    with SingleTickerProviderStateMixin {
  final _repo = ReportesRepository();
  final _export = ExportService();
  late TabController _tabController;

  Map<String, double> _egresosPorCategoria = {};
  Map<String, double> _ingresosPorCategoria = {};
  Map<String, double> _produccionPorCultivo = {};
  Map<String, int> _animalesPorRaza = {};
  Map<String, double> _costoMantenimiento = {};
  Map<int, (double, double)> _rentabilidad = {};
  bool _cargando = true;

  final _tabs = const ['Finanzas', 'Producción', 'Ganado', 'Maquinaria'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final egresos = await _repo.egresosPorCategoria();
    final ingresos = await _repo.ingresosPorCategoria();
    final produccion = await _repo.produccionPorCultivo();
    final razas = await _repo.animalesPorRaza();
    final mantenimiento = await _repo.costoMantenimientoPorMaquina();
    final rentabilidad = await _repo.rentabilidadPorMes(DateTime.now().year);
    if (!mounted) return;
    setState(() {
      _egresosPorCategoria = egresos;
      _ingresosPorCategoria = ingresos;
      _produccionPorCultivo = produccion;
      _animalesPorRaza = razas;
      _costoMantenimiento = mantenimiento;
      _rentabilidad = rentabilidad;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 Reportes', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.reportes,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _TabFinanzas(
                        egresos: _egresosPorCategoria,
                        ingresos: _ingresosPorCategoria,
                        rentabilidad: _rentabilidad,
                        export: _export,
                      ),
                      _TabProduccion(
                        produccion: _produccionPorCultivo,
                        export: _export,
                      ),
                      _TabGanado(razas: _animalesPorRaza, export: _export),
                      _TabMaquinaria(
                          costos: _costoMantenimiento, export: _export),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExportButtons extends StatelessWidget {
  final String titulo;
  final Map<String, num> datos;
  final ExportService export;
  final String unidad;

  const _ExportButtons({
    required this.titulo,
    required this.datos,
    required this.export,
    this.unidad = r'$',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: datos.isEmpty
              ? null
              : () => export.exportarExcel(titulo: titulo, datos: datos),
          icon: const Icon(Icons.grid_on_rounded, size: 18),
          label: const Text('Excel'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: datos.isEmpty
              ? null
              : () => export.exportarPdf(
                  titulo: titulo, datos: datos, unidad: unidad),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
          label: const Text('PDF'),
        ),
      ],
    );
  }
}

class _TabFinanzas extends StatelessWidget {
  final Map<String, double> egresos;
  final Map<String, double> ingresos;
  final Map<int, (double, double)> rentabilidad;
  final ExportService export;

  const _TabFinanzas({
    required this.egresos,
    required this.ingresos,
    required this.rentabilidad,
    required this.export,
  });

  static const _meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'es_AR', symbol: r'$');
    final maxValor = rentabilidad.values
        .expand((v) => [v.$1, v.$2])
        .fold<double>(0, (a, b) => b > a ? b : a);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rentabilidad mensual (año actual)',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: rentabilidad.isEmpty
                ? const Center(child: Text('Sin datos'))
                : BarChart(
                    BarChartData(
                      maxY: maxValor == 0 ? 10 : maxValor * 1.2,
                      barGroups: [
                        for (var mes = 1; mes <= 12; mes++)
                          BarChartGroupData(x: mes, barRods: [
                            BarChartRodData(
                              toY: rentabilidad[mes]?.$1 ?? 0,
                              color: AppColors.success,
                              width: 6,
                            ),
                            BarChartRodData(
                              toY: rentabilidad[mes]?.$2 ?? 0,
                              color: AppColors.danger,
                              width: 6,
                            ),
                          ]),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(_meses[value.toInt() - 1],
                                  style: const TextStyle(fontSize: 10)),
                            ),
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Leyenda(color: AppColors.success, texto: 'Ingresos'),
              const SizedBox(width: 16),
              _Leyenda(color: AppColors.danger, texto: 'Egresos'),
            ],
          ),
          const SizedBox(height: 32),
          Text('Egresos por categoría', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _GraficoTorta(datos: egresos, currency: currency),
          const SizedBox(height: 12),
          _ExportButtons(
              titulo: 'Egresos por categoría', datos: egresos, export: export),
          const SizedBox(height: 32),
          Text('Ingresos por categoría', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _GraficoTorta(datos: ingresos, currency: currency),
          const SizedBox(height: 12),
          _ExportButtons(
              titulo: 'Ingresos por categoría', datos: ingresos, export: export),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TabProduccion extends StatelessWidget {
  final Map<String, double> produccion;
  final ExportService export;
  const _TabProduccion({required this.produccion, required this.export});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Producción por cultivo', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _GraficoBarrasHorizontal(datos: produccion, color: AppColors.cultivos),
          const SizedBox(height: 12),
          _ExportButtons(
            titulo: 'Producción por cultivo',
            datos: produccion,
            export: export,
            unidad: 'unidades',
          ),
        ],
      ),
    );
  }
}

class _TabGanado extends StatelessWidget {
  final Map<String, int> razas;
  final ExportService export;
  const _TabGanado({required this.razas, required this.export});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final datos = razas.map((k, v) => MapEntry(k, v.toDouble()));
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Animales activos por raza', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _GraficoBarrasHorizontal(datos: datos, color: AppColors.ganado),
          const SizedBox(height: 12),
          _ExportButtons(
            titulo: 'Evolución del ganado',
            datos: datos,
            export: export,
            unidad: 'animales',
          ),
        ],
      ),
    );
  }
}

class _TabMaquinaria extends StatelessWidget {
  final Map<String, double> costos;
  final ExportService export;
  const _TabMaquinaria({required this.costos, required this.export});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Costo de mantenimiento por máquina',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _GraficoBarrasHorizontal(datos: costos, color: AppColors.maquinaria),
          const SizedBox(height: 12),
          _ExportButtons(
            titulo: 'Mantenimiento de maquinaria',
            datos: costos,
            export: export,
          ),
        ],
      ),
    );
  }
}

class _GraficoTorta extends StatelessWidget {
  final Map<String, double> datos;
  final NumberFormat currency;
  const _GraficoTorta({required this.datos, required this.currency});

  static const _colores = [
    AppColors.primaryGreen,
    AppColors.earthBrown,
    AppColors.wheatGold,
    AppColors.info,
    AppColors.danger,
    AppColors.grayMedium,
  ];

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty || datos.values.every((v) => v == 0)) {
      return const SizedBox(
          height: 160, child: Center(child: Text('Sin datos todavía')));
    }
    final total = datos.values.fold<double>(0, (a, b) => a + b);
    final entradas = datos.entries.toList();

    return Row(
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (var i = 0; i < entradas.length; i++)
                  PieChartSectionData(
                    value: entradas[i].value,
                    color: _colores[i % _colores.length],
                    title: '${(entradas[i].value / total * 100).toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                        fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < entradas.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: _colores[i % _colores.length], shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entradas[i].key, overflow: TextOverflow.ellipsis)),
                      Text(currency.format(entradas[i].value)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GraficoBarrasHorizontal extends StatelessWidget {
  final Map<String, double> datos;
  final Color color;
  const _GraficoBarrasHorizontal({required this.datos, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (datos.isEmpty) {
      return const SizedBox(
          height: 160, child: Center(child: Text('Sin datos todavía')));
    }
    final maxValor = datos.values.fold<double>(0, (a, b) => b > a ? b : a);

    return Column(
      children: datos.entries.map((e) {
        final proporcion = maxValor == 0 ? 0.0 : e.value / maxValor;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(e.key,
                    style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: proporcion.clamp(0, 1),
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 60,
                child: Text(e.value.toStringAsFixed(0),
                    style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;
  const _Leyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(texto, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
