import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_app/presentation/controllers/maker_provider.dart';
import 'package:new_app/presentation/widgets/maker/maker_form_card.dart';

import '../../widgets/common/app_state_views.dart';
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
        loading: () => const AppLoadingView(color: Color(0xFF4F46E5)),
        error: (err, _) => AppErrorView(
          message: 'Failed to load forms: $err',
          onRetry: () => ref.refresh(makerFormsProvider(productId)),
        ),
        data: (forms) {
          if (forms.isEmpty) {
            return const AppEmptyScopeView(
              message: 'No forms associated with this product.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: forms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final form = forms[index];
              return MakerFormCard(
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
