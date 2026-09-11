import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_app/app/app_assets.dart';

class AccountItem {
  const AccountItem({
    required this.id,
    required this.name,
    required this.balance,
    this.svgAssetPath,
    this.fallbackIcon = Icons.account_balance_wallet_rounded,
  });

  final String id;
  final String name;
  final double balance;
  final String? svgAssetPath;
  final IconData fallbackIcon;
}

class AccountSelectorModal extends StatefulWidget {
  const AccountSelectorModal({
    super.key,
    required this.selectedAccountId,
    required this.onSelected,
    this.accounts = const [
      AccountItem(
        id: 'all',
        name: 'All Accounts',
        balance: 200402.0, // Combined total
        fallbackIcon: Icons.account_balance_wallet_rounded,
      ),
      AccountItem(
        id: 'current',
        name: 'Current *6303',
        balance: 100201.0,
        svgAssetPath: AppAssets.currentAccountSvg,
        fallbackIcon: Icons.account_balance_rounded,
      ),
      AccountItem(
        id: 'savings',
        name: 'Savings *3940',
        balance: 100201.0,
        svgAssetPath: AppAssets.savingsAccountSvg,
        fallbackIcon: Icons.savings_rounded,
      ),
    ],
  });

  final String selectedAccountId;
  final List<AccountItem> accounts;
  final ValueChanged<AccountItem> onSelected;

  static Future<void> show(
    BuildContext context, {
    required String currentAccountId,
    required ValueChanged<AccountItem> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => AccountSelectorModal(
        selectedAccountId: currentAccountId,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<AccountSelectorModal> createState() => _AccountSelectorModalState();
}

class _AccountSelectorModalState extends State<AccountSelectorModal> {
  late String _currentSelectedId;

  static const Color handleColor = Color(0xFFD2D2D2);
  static const Color brandPurple = Color(0xFF6347D1);
  static const Color titleColor = Color(0xFF1E1E1E);
  static const Color subtitleColor = Color(0xFF71717A);
  static const Color unselectedRadioBorder = Color(0xFFCBD5E1);

  @override
  void initState() {
    super.initState();
    _currentSelectedId = widget.selectedAccountId;
  }

  String _formatBalance(double amount) {
    final intVal = amount.round();
    final parts = intVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return 'Balance: Rs. $parts';
  }

  void _onConfirm() {
    final picked = widget.accounts.firstWhere(
      (a) => a.id == _currentSelectedId || a.name == _currentSelectedId,
      orElse: () => widget.accounts.first,
    );
    widget.onSelected(picked);
    Navigator.of(context).pop();
  }

  Widget _buildCircularLogo(AccountItem account) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
      ),
      child: account.svgAssetPath != null
          ? SvgPicture.asset(
              account.svgAssetPath!,
              fit: BoxFit.contain,
              placeholderBuilder: (_) =>
                  Icon(account.fallbackIcon, size: 20, color: brandPurple),
            )
          : Icon(account.fallbackIcon, size: 20, color: brandPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: 343,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 343,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.centerLeft,
                  stops: [0.0, 0.55, 1.0],
                  colors: [
                    Color(0xFFDCD1FF), // Soft purple glow in top right
                    Color(0xFFF7F5FF),
                    Color(0xFFFFFFFF), // Pure white bottom behind Select button
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x351E1B4B),
                    blurRadius: 36,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Select Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (int i = 0; i < widget.accounts.length; i++) ...[
                          _buildAccountRow(widget.accounts[i]),
                          if (i < widget.accounts.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0x1F000000),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Select',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountRow(AccountItem account) {
    final isSelected =
        account.id == _currentSelectedId || account.name == _currentSelectedId;

    return InkWell(
      onTap: () => setState(() => _currentSelectedId = account.id),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            _buildCircularLogo(account),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatBalance(account.balance),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? brandPurple : Colors.transparent,
                border: Border.all(
                  color: isSelected ? brandPurple : unselectedRadioBorder,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
