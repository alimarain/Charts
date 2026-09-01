import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/features/maker/controller/maker_provider.dart';

import '../../domain/entities/maker_models.dart';
import 'dynamic_form_screen.dart';

class MakerFormsScreen extends ConsumerWidget {
  const MakerFormsScreen({
    required this.productId,
    this.productName,
    super.key,
  });

  static const routeName = 'maker_forms';
  static const routeSubPath = 'products/:productId/forms';

  final String productId;
  final String? productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formsAsync = ref.watch(makerFormsProvider(productId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(productName ?? 'Available Form Templates')),
      body: formsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ),
        error: (err, _) => Center(child: Text('Failed to load forms: $err')),
        data: (forms) {
          if (forms.isEmpty) {
            return const Center(
              child: Text('No forms associated with this product.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: forms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final form = forms[index];
              return _MakerFormCard(
                form: form,
                onTap: () {
                  context.pushNamed(
                    DynamicFormScreen.routeName,
                    pathParameters: {'formId': form.id},
                    extra: form.title,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MakerFormCard extends StatelessWidget {
  const _MakerFormCard({required this.form, required this.onTap});

  final MakerForm form;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      form.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${form.fieldCount} Fields',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                form.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Open Dynamic Form',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Color(0xFF4F46E5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
