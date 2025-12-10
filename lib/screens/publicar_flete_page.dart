import 'package:flutter/material.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/models/flete.dart';
import 'package:intl/intl.dart';

class PublicarFletePage extends StatefulWidget {
  final String clienteId;

  const PublicarFletePage({super.key, required this.clienteId});

  @override
  State<PublicarFletePage> createState() => _PublicarFletePageState();
}

class _PublicarFletePageState extends State<PublicarFletePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers existentes
  final _numeroContenedorController = TextEditingController();
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();
  final _tarifaController = TextEditingController();
  
  // Controllers FASE 2/3
  final _pesoCargaNetaController = TextEditingController();
  final _pesoTaraController = TextEditingController();
  final _puertoOrigenController = TextEditingController();
  final _direccionDestinoController = TextEditingController();
  final _devolucionCtnVacioController = TextEditingController();
  final _requisitosEspecialesController = TextEditingController();
  final _serviciosAdicionalesController = TextEditingController();
  
  // MÓDULO 2: Controllers nuevos
  final _valorPerimetroController = TextEditingController();
  final _tipoRamplaController = TextEditingController();
  
  final _fleteService = FleteService();
  
  String _tipoContenedor = 'CTN Std 20';
  String _puertoOrigen = 'San Antonio'; // MÓDULO 2: Puerto por defecto
  DateTime? _fechaHoraCarga;
  bool _isLoading = false;
  
  // MÓDULO 2: Estados nuevos
  bool _isFueraDePerimetro = false;
  double? _valorAdicionalSobrepeso;
  bool _mostrarAlertaSobrepeso = false;

  @override
  void dispose() {
    _numeroContenedorController.dispose();
    _origenController.dispose();
    _destinoController.dispose();
    _tarifaController.dispose();
    _pesoCargaNetaController.dispose();
    _pesoTaraController.dispose();
    _puertoOrigenController.dispose();
    _direccionDestinoController.dispose();
    _devolucionCtnVacioController.dispose();
    _requisitosEspecialesController.dispose();
    _serviciosAdicionalesController.dispose();
    // MÓDULO 2
    _valorPerimetroController.dispose();
    _tipoRamplaController.dispose();
    super.dispose();
  }

  double _calcularPesoTotal() {
    final cargaNeta = double.tryParse(_pesoCargaNetaController.text) ?? 0;
    final tara = double.tryParse(_pesoTaraController.text) ?? 0;
    final pesoTotal = cargaNeta + tara;
    
    // MÓDULO 2: Validar sobrepeso (> 25 toneladas = 25,000 kg)
    if (pesoTotal > 25000) {
      if (!_mostrarAlertaSobrepeso) {
        setState(() => _mostrarAlertaSobrepeso = true);
      }
    } else {
      if (_mostrarAlertaSobrepeso) {
        setState(() {
          _mostrarAlertaSobrepeso = false;
          _valorAdicionalSobrepeso = null;
        });
      }
    }
    
    return pesoTotal;
  }

  Future<void> _seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null && mounted) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (hora != null && mounted) {
        setState(() {
          _fechaHoraCarga = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final pesoTotal = _calcularPesoTotal();
      
      final flete = Flete(
        clienteId: widget.clienteId,
        tipoContenedor: _tipoContenedor,
        numeroContenedor: _numeroContenedorController.text.trim(),
        pesoCargaNeta: double.tryParse(_pesoCargaNetaController.text.trim()),
        pesoTara: double.tryParse(_pesoTaraController.text.trim()),
        peso: pesoTotal,
        origen: _origenController.text.trim(),
        puertoOrigen: _puertoOrigen, // MÓDULO 2: Usar dropdown
        destino: _destinoController.text.trim(),
        direccionDestino: _direccionDestinoController.text.isNotEmpty 
            ? _direccionDestinoController.text.trim() 
            : null,
        fechaHoraCarga: _fechaHoraCarga,
        devolucionCtnVacio: _devolucionCtnVacioController.text.isNotEmpty 
            ? _devolucionCtnVacioController.text.trim() 
            : null,
        requisitosEspeciales: _requisitosEspecialesController.text.isNotEmpty 
            ? _requisitosEspecialesController.text.trim() 
            : null,
        serviciosAdicionales: _serviciosAdicionalesController.text.isNotEmpty 
            ? _serviciosAdicionalesController.text.trim() 
            : null,
        // MÓDULO 2: Campos nuevos
        isFueraDePerimetro: _isFueraDePerimetro,
        valorAdicionalPerimetro: _isFueraDePerimetro && _valorPerimetroController.text.isNotEmpty
            ? double.tryParse(_valorPerimetroController.text.trim())
            : null,
        valorAdicionalSobrepeso: _valorAdicionalSobrepeso,
        tipoDeRampla: _tipoRamplaController.text.isNotEmpty
            ? _tipoRamplaController.text.trim()
            : null,
        tarifa: double.parse(_tarifaController.text.trim()),
        estado: 'disponible',
        fechaPublicacion: now,
        createdAt: now,
        updatedAt: now,
      );

      await _fleteService.publicarFlete(flete);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Flete publicado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pesoTotal = _calcularPesoTotal();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Nuevo Flete'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== SECCIÓN 1: DETALLES DEL CONTENEDOR ==========
              _buildSectionHeader(context, 'Detalles del Contenedor', Icons.inventory_2),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _tipoContenedor,
                decoration: _inputDecoration('Tipo de Contenedor', Icons.category_outlined),
                items: const [
                  DropdownMenuItem(value: 'CTN Std 20', child: Text('Contenedor Std 20\'')),
                  DropdownMenuItem(value: 'CTN Std 40', child: Text('Contenedor Std 40\'')),
                  DropdownMenuItem(value: 'HC', child: Text('High Cube (HC)')),
                  DropdownMenuItem(value: 'OT', child: Text('Open Top (OT)')),
                  DropdownMenuItem(value: 'reefer', child: Text('Reefer (Refrigerado)')),
                ],
                onChanged: (value) => setState(() => _tipoContenedor = value!),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _numeroContenedorController,
                decoration: _inputDecoration('Número de Contenedor *', Icons.tag_outlined),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              
              const SizedBox(height: 24),
              
              // ========== SECCIÓN 2: PESO ==========
              _buildSectionHeader(context, 'Información de Peso', Icons.scale),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pesoCargaNetaController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Carga Neta (kg)', Icons.inventory),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pesoTaraController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Tara (kg)', Icons.scale_outlined),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              
              if (pesoTotal > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calculate, 
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Peso Total: ${pesoTotal.toStringAsFixed(0)} kg',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // MÓDULO 2: Alert de sobrepeso
              if (_mostrarAlertaSobrepeso) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, 
                            color: Colors.orange.shade800,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '⚠️ SOBREPESO DETECTADO',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'El peso total excede las 25 toneladas (25,000 kg). Se recomienda añadir un valor adicional por sobrepeso.',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Valor Adicional por Sobrepeso (opcional)',
                          prefixText: '\$ ',
                          prefixIcon: Icon(Icons.attach_money, color: Colors.orange.shade700),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.orange.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.orange.shade300),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _valorAdicionalSobrepeso = double.tryParse(value);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // ========== SECCIÓN 3: ORIGEN Y FECHA ==========
              _buildSectionHeader(context, 'Origen y Fecha de Carga', Icons.place),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _origenController,
                decoration: _inputDecoration('Puerto/Ciudad Origen *', Icons.place_outlined),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              
              // MÓDULO 2: Dropdown Puerto Origen (Fijo)
              DropdownButtonFormField<String>(
                value: _puertoOrigen,
                decoration: _inputDecoration('Puerto Específico *', Icons.anchor),
                items: const [
                  DropdownMenuItem(value: 'San Antonio', child: Text('San Antonio')),
                  DropdownMenuItem(value: 'Valparaíso', child: Text('Valparaíso')),
                ],
                onChanged: (value) => setState(() => _puertoOrigen = value!),
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _seleccionarFechaHora,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _inputDecoration('Fecha y Hora de Carga', Icons.schedule),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fechaHoraCarga == null
                            ? 'Seleccionar fecha y hora'
                            : DateFormat('dd/MM/yyyy - HH:mm').format(_fechaHoraCarga!),
                        style: TextStyle(
                          color: _fechaHoraCarga == null 
                              ? Theme.of(context).hintColor 
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ========== SECCIÓN 4: DESTINO ==========
              _buildSectionHeader(context, 'Destino', Icons.location_on),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _destinoController,
                decoration: _inputDecoration('Ciudad/Región Destino *', Icons.location_on_outlined),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _direccionDestinoController,
                decoration: _inputDecoration('Dirección Completa (opcional)', Icons.home_outlined),
                maxLines: 2,
              ),
              
              // MÓDULO 2: Checkbox Perímetro
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: _isFueraDePerimetro 
                      ? Colors.blue.shade50 
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isFueraDePerimetro 
                        ? Colors.blue.shade300 
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text(
                        '¿Dirección fuera del perímetro urbano?',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Marcar si el destino está fuera de la ciudad',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isFueraDePerimetro,
                      onChanged: (value) {
                        setState(() => _isFueraDePerimetro = value ?? false);
                      },
                      activeColor: Colors.blue.shade700,
                    ),
                    if (_isFueraDePerimetro) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: TextFormField(
                          controller: _valorPerimetroController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Valor Adicional por Perímetro',
                            prefixText: '\$ ',
                            prefixIcon: const Icon(Icons.add_circle_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            helperText: 'Costo adicional por entrega fuera de perímetro',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // MÓDULO 2: SECCIÓN DATOS DE INGRESO A PUERTOS
              _buildSectionHeader(context, 'Datos de Ingreso a Puertos', Icons.security),
              const SizedBox(height: 8),
              Text(
                'RUTs requeridos para el ingreso del camión a los puertos',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              
              // MÓDULO 2: SECCIÓN INFORMACIÓN DE RAMPLA
              _buildSectionHeader(context, 'Información de Rampla y Requisitos', Icons.local_shipping),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _tipoRamplaController,
                decoration: _inputDecoration('Tipo de Rampla (opcional)', Icons.rv_hookup_outlined).copyWith(
                  helperText: 'Ej: Plataforma, Cama baja, Especial',
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _requisitosEspecialesController,
                decoration: _inputDecoration('Requisitos Especiales', Icons.warning_amber).copyWith(
                  helperText: 'Ej: Manipulación especial, temperatura, documentación extra',
                  helperMaxLines: 2,
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // ========== SECCIÓN 5: INFORMACIÓN ADICIONAL ==========
              _buildSectionHeader(context, 'Información Adicional', Icons.info_outline),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _devolucionCtnVacioController,
                decoration: _inputDecoration('Devolución Contenedor Vacío', Icons.turn_left).copyWith(
                  helperText: 'Dirección/instrucciones para devolver el contenedor',
                  helperMaxLines: 2,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _serviciosAdicionalesController,
                decoration: _inputDecoration('Servicios Adicionales', Icons.add_circle_outline).copyWith(
                  helperText: 'Ej: Escolta, seguro adicional, embalaje especial',
                  helperMaxLines: 2,
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 24),
              
              // ========== SECCIÓN 6: TARIFA ==========
              _buildSectionHeader(context, 'Tarifa', Icons.attach_money),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _tarifaController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Tarifa Base (\$) + IVA *', Icons.payments_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Tarifa inválida';
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // ========== BOTÓN PUBLICAR ==========
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _publicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.publish),
                            SizedBox(width: 8),
                            Text('Publicar Flete', 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    );
  }
}
