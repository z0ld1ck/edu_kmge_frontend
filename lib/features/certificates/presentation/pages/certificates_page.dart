import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/entities/certificate.dart';
import '../controllers/certificates_controller.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<CertificatesController>()..load(),
      child: const _CertificatesView(),
    );
  }
}

class _CertificatesView extends StatelessWidget {
  const _CertificatesView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CertificatesController>();
    return AppShell(
      title: 'Мои сертификаты',
      current: '/certificates',
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.error != null
          ? Center(child: Text('Ошибка: ${ctrl.error}'))
          : ctrl.items.isEmpty
          ? _empty()
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [for (final c in ctrl.items) _tile(context, ctrl, c)],
      ),
    );
  }

  Widget _empty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.workspace_premium_outlined,
            size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        const Text('Пока нет сертификатов.\nЗавершите курс и сдайте тест.',
            textAlign: TextAlign.center),
      ],
    ),
  );

  Widget _tile(
      BuildContext context, CertificatesController ctrl, Certificate c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: const CircleAvatar(
          backgroundColor: AppColors.brand,
          child: Icon(Icons.workspace_premium, color: Colors.white),
        ),
        title: Text(c.courseTitle ?? 'Курс',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '№ ${c.serialNumber}  •  Результат: ${c.score.toStringAsFixed(0)}%'),
        trailing: FilledButton.icon(
          onPressed: () => ctrl.download(c),
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Скачать PDF'),
        ),
      ),
    );
  }
}
