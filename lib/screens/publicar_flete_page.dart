import 'package:flutter/material.dart';
import 'package:cargoclick/services/flete_service.dart';
import 'package:cargoclick/models/flete.dart';

class PublicarFletePage extends StatefulWidget {
  final String clienteId;

  const PublicarFletePage({super.key, required this.clienteId});

  @override
  State<PublicarFletePage> createState() => _PublicarFletePageState();
}

class _PublicarFletePageState extends State<PublicarFletePage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroContenedorController = TextEditingController();
  final _pesoController = TextEditingController();
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();
  final _tarifaController = TextEditingController();
  final _fleteService = FleteService();
  String _tipoContenedor = '20ft';
  bool _isLoading = false;

  @override
  void dispose() {
    _numeroContenedorController.dispose();
    _pesoController.dispose();
    _origenController.dispose();
    _destinoController.dispose();
    _tarifaController.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final flete = Flete(
        clienteId: widget.clienteId,
        tipoContenedor: _tipoContenedor,
        numeroContenedor: _numeroContenedorController.text.trim(),
        peso: double.parse(_pesoController.text.trim()),
        origen: _origenController.text.trim(),
        destino: _destinoController.text.trim(),
        tarifa: double.parse(_tarifaController.text.trim()),
        estado: 'publicado',
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
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 16),
              Text(
                'Detalles del Contenedor',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _tipoContenedor,
                decoration: InputDecoration(
                  labelText: 'Tipo de Contenedor',
                  prefixIcon: const Icon(Icons.inventory_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                items: const [
                  DropdownMenuItem(value: '20ft', child: Text('20ft')),
                  DropdownMenuItem(value: '40ft', child: Text('40ft')),
                  DropdownMenuItem(value: '40ft HC', child: Text('40ft HC')),
                ],
                onChanged: (value) => setState(() => _tipoContenedor = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroContenedorController,
                decoration: InputDecoration(
                  labelText: 'Número de Contenedor',
                  prefixIcon: const Icon(Icons.tag_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa el número' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pesoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: const Icon(Icons.scale_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa el peso';
                  if (double.tryParse(value) == null) return 'Peso inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Ruta',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _origenController,
                decoration: InputDecoration(
                  labelText: 'Origen',
                  prefixIcon: const Icon(Icons.place_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa el origen' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinoController,
                decoration: InputDecoration(
                  labelText: 'Destino',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa el destino' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Tarifa',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tarifaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tarifa (\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa la tarifa';
                  if (double.tryParse(value) == null) return 'Tarifa inválida';
                  return null;
                },
              ),
              const SizedBox(height: 32),
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
                      : const Text('Publicar Flete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
